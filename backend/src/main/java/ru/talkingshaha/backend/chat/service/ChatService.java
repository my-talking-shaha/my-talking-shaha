package ru.talkingshaha.backend.chat.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.analytics.dto.AnalyticsOverviewResponse;
import ru.talkingshaha.backend.analytics.model.AnalyticsPeriod;
import ru.talkingshaha.backend.analytics.service.AnalyticsService;
import ru.talkingshaha.backend.chat.dto.ChatActionResponse;
import ru.talkingshaha.backend.chat.dto.ChatMessageResponse;
import ru.talkingshaha.backend.chat.dto.ChatMessagesResponse;
import ru.talkingshaha.backend.chat.dto.ChatStateResponse;
import ru.talkingshaha.backend.chat.dto.SendMessageResponse;
import ru.talkingshaha.backend.chat.dto.SendMessageRequest;
import ru.talkingshaha.backend.chat.model.ChatMessage;
import ru.talkingshaha.backend.chat.model.ChatMessageRole;
import ru.talkingshaha.backend.chat.model.ChatSession;
import ru.talkingshaha.backend.chat.repository.ChatMessageRepository;
import ru.talkingshaha.backend.chat.repository.ChatSessionRepository;
import ru.talkingshaha.backend.part.dto.PartResponse;
import ru.talkingshaha.backend.part.model.PartStatus;
import ru.talkingshaha.backend.timeline.dto.CreateMaintenanceEventRequest;
import ru.talkingshaha.backend.timeline.dto.CreateRefuelEventRequest;
import ru.talkingshaha.backend.timeline.dto.CreateTripEventRequest;
import ru.talkingshaha.backend.timeline.dto.TimelineEventResponse;
import ru.talkingshaha.backend.timeline.service.TimelineEventService;
import ru.talkingshaha.backend.vehicle.dto.VehicleDashboardResponse;
import ru.talkingshaha.backend.vehicle.model.FuelType;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.service.VehicleService;

@Service
public class ChatService {

    private static final Logger log = LoggerFactory.getLogger(ChatService.class);

    private static final String UNIT_END = "(?=$|\\s|[.,!?;:])";
    private static final Pattern LITERS_PATTERN = Pattern.compile("(-?\\d+(?:[.,]\\d+)?)\\s*(?:l|liter|liters|л|литр|литра|литров)" + UNIT_END, Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final Pattern MONEY_PATTERN = Pattern.compile("(?:за|for|cost|стоим(?:ость)?|стоил[ао]?|цена)?\\s*(-?\\d+(?:[.,]\\d+)?)\\s*(?:rub|ruble|rubles|₽|р|руб|рублей|рубля)" + UNIT_END, Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final Pattern MILEAGE_PATTERN = Pattern.compile("(?:mileage|odometer|пробег|на пробеге)\\D{0,12}(-?\\d+)\\s*(?:km|км)" + UNIT_END, Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final Pattern DISTANCE_PATTERN = Pattern.compile("(-?\\d+)\\s*(?:km|км)" + UNIT_END, Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final Pattern DURATION_PATTERN = Pattern.compile("(-?\\d+)\\s*(?:min|mins|minute|minutes|мин|минут|минуты)" + UNIT_END, Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final Pattern HOURS_PATTERN = Pattern.compile("(-?\\d+)\\s*(?:h|hour|hours|час|часа|часов)" + UNIT_END, Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final Pattern TEXT_DATE_PATTERN = Pattern.compile(
            "(?<!\\d)(\\d{1,2})(?:\\s*[-–—]?\\s*(?:го|ое|е))?\\s+"
                    + "(января|январь|февраля|февраль|марта|март|апреля|апрель|мая|май|июня|июнь|июля|июль|"
                    + "августа|август|сентября|сентябрь|октября|октябрь|ноября|ноябрь|декабря|декабрь)"
                    + "(?:\\s+(\\d{4}))?(?!\\p{L})",
            Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final Pattern NUMERIC_DATE_PATTERN = Pattern.compile("\\b(\\d{1,2})[./-](\\d{1,2})(?:[./-](\\d{2,4}))?\\b");
    private static final Pattern FUEL_GRADE_PATTERN = Pattern.compile("(?:ai[-\\s]?)?(\\d{2,3})\\s*(?:[-\\s]?(?:й|м))?\\s*(?:gas|fuel|petrol|бенз|бензин)", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final List<String> SUPPORTED_FUEL_NAMES = List.of("92 octane", "95 octane", "98 octane", "Diesel");

    private final VehicleService vehicles;
    private final AnalyticsService analytics;
    private final ChatSessionRepository sessions;
    private final ChatMessageRepository messages;
    private final ChatIntentResolver intentResolver;
    private final AiChatClient aiChatClient;
    private final TimelineEventService timelineEvents;
    private final ObjectMapper objectMapper;

    public ChatService(
            VehicleService vehicles,
            AnalyticsService analytics,
            ChatSessionRepository sessions,
            ChatMessageRepository messages,
            ChatIntentResolver intentResolver,
            AiChatClient aiChatClient,
            TimelineEventService timelineEvents,
            ObjectMapper objectMapper) {
        this.vehicles = vehicles;
        this.analytics = analytics;
        this.sessions = sessions;
        this.messages = messages;
        this.intentResolver = intentResolver;
        this.aiChatClient = aiChatClient;
        this.timelineEvents = timelineEvents;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public ChatStateResponse state(UUID vehicleId) {
        return state(vehicleId, ChatLanguage.EN);
    }

    @Transactional
    public ChatStateResponse state(UUID vehicleId, ChatLanguage language) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        ChatSession session = getOrCreateSession(vehicle, language);
        List<ChatMessageResponse> history = messages.findAllBySessionOrderByCreatedAtAsc(session).stream()
                .map(this::toResponse)
                .toList();
        return new ChatStateResponse(session.getId(), quickQuestions(history, language), history);
    }

    @Transactional
    public ChatMessagesResponse messages(UUID vehicleId) {
        return messages(vehicleId, ChatLanguage.EN);
    }

    @Transactional
    public ChatMessagesResponse messages(UUID vehicleId, ChatLanguage language) {
        return new ChatMessagesResponse(state(vehicleId, language).messages());
    }

    @Transactional
    public ChatSession activeSession(UUID vehicleId, ChatLanguage language) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        return getOrCreateSession(vehicle, language);
    }

    @Transactional
    public SendMessageResponse send(UUID vehicleId, SendMessageRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        ChatSession session = getOrCreateSession(vehicle, ChatLanguage.EN);
        ChatMessage userMessage = saveMessage(session, ChatMessageRole.USER, request.text());

        VehicleDashboardResponse dashboard = vehicles.dashboard(vehicleId);
        AnalyticsOverviewResponse analyticsOverview = analytics.overview(vehicleId, AnalyticsPeriod.ALL_TIME, null, null);
        String baseContext = context(dashboard, analyticsOverview);
        ChatDecision decision = intentResolver.resolve(request.text(), baseContext);
        AssistantDraft assistantDraft = assistantDraft(request.text(), decision, session, vehicle, dashboard, analyticsOverview);
        ChatMessage assistantMessage = saveMessage(
                session,
                ChatMessageRole.ASSISTANT,
                assistantDraft.text(),
                assistantDraft.action());

        return new SendMessageResponse(
                toResponse(userMessage),
                toResponse(assistantMessage),
                assistantDraft.createdEvent());
    }

    private AssistantDraft assistantDraft(
            String userText,
            ChatDecision decision,
            ChatSession session,
            Vehicle vehicle,
            VehicleDashboardResponse dashboard,
            AnalyticsOverviewResponse analyticsOverview) {
        Optional<AssistantDraft> createdEventDraft = autoCreateEvent(userText, decision, session, vehicle);
        if (createdEventDraft.isPresent()) {
            return createdEventDraft.get();
        }
        ChatActionResponse action = action(decision, userText);
        String context = contextForDecision(decision, dashboard, analyticsOverview, action);
        String text = aiChatClient.answer(userText, decision, context)
                .orElseGet(() -> templateAnswer(userText, decision, dashboard, analyticsOverview, action));
        return new AssistantDraft(polishAssistantText(text, userText, decision.language()), action, null);
    }

    private Optional<AssistantDraft> autoCreateEvent(
            String userText,
            ChatDecision decision,
            ChatSession session,
            Vehicle vehicle) {
        try {
            if (decision.intent() == ChatIntent.OPEN_TRIP_FORM && startsTripConversation(userText)) {
                return startTripFromChatMessage(userText, session, vehicle);
            }
            Optional<ChatActionResponse> pending = latestPendingAction(session);
            if (pending.isPresent()) {
                return continuePendingEvent(userText, pending.get(), session, vehicle);
            }
            if (decision.intent() == ChatIntent.OPEN_TRIP_FORM && endsTripConversation(userText)) {
                return endActiveTripFromChatMessage(userText, session, vehicle);
            }
            if (asksForRequiredFields(userText)) {
                Map<String, Object> fields = prefill(userText);
                return switch (decision.intent()) {
                    case OPEN_REFUEL_FORM -> Optional.of(new AssistantDraft(refuelRequiredFieldsAnswer(), pendingAction("REFUEL", fields), null));
                    case OPEN_TRIP_FORM -> Optional.of(new AssistantDraft(tripRequiredFieldsAnswer(), pendingAction("TRIP", fields), null));
                    case OPEN_REPAIR_FORM -> Optional.of(new AssistantDraft(maintenanceRequiredFieldsAnswer(), pendingAction("MAINTENANCE", fields), null));
                    default -> Optional.empty();
                };
            }
            return switch (decision.intent()) {
                case OPEN_REFUEL_FORM -> createRefuelFromText(userText, vehicle, Map.of());
                case OPEN_TRIP_FORM -> createTripFromText(userText, vehicle, Map.of());
                case OPEN_REPAIR_FORM -> createMaintenanceFromText(userText, vehicle, Map.of());
                default -> Optional.empty();
            };
        } catch (RuntimeException exception) {
            log.warn("Failed to create timeline event from chat message: {}", exception.getMessage());
            return Optional.empty();
        }
    }

    private Optional<AssistantDraft> continuePendingEvent(
            String userText,
            ChatActionResponse pending,
            ChatSession session,
            Vehicle vehicle) {
        Map<String, Object> merged = new LinkedHashMap<>(pending.prefill());
        Map<String, Object> newFields = prefill(userText);
        if ("REFUEL".equals(pending.form())) {
            shortFuelName(userText).ifPresent(value -> newFields.put("fuelName", value));
        }
        merged.putAll(newFields);
        return switch (pending.form()) {
            case "REFUEL" -> createRefuelFromText(userText, vehicle, merged);
            case "TRIP" -> uuidField(merged, "tripId")
                    .map(tripId -> updateLifecycleTripFromText(userText, vehicle, session, tripId, merged))
                    .orElseGet(() -> createTripFromText(userText, vehicle, merged));
            case "MAINTENANCE" -> createMaintenanceFromText(userText, vehicle, merged);
            default -> Optional.empty();
        };
    }

    private Optional<AssistantDraft> createRefuelFromText(
            String userText,
            Vehicle vehicle,
            Map<String, Object> carriedFields) {
        Map<String, Object> fields = mergedFields(carriedFields, prefill(userText));
        fields.putIfAbsent("mileageKm", vehicle.getMileageKm());
        fields.putIfAbsent("fuelType", fuelType(userText, vehicle).name());

        List<String> errors = refuelValidationErrors(fields, vehicle);
        if (!errors.isEmpty()) {
            return Optional.of(new AssistantDraft(missingOrInvalidAnswer("заправку", errors), pendingAction("REFUEL", fields), null));
        }

        Integer mileageKm = integerField(fields, "mileageKm").orElseThrow();
        BigDecimal liters = decimalField(fields, "liters").orElseThrow();
        BigDecimal cost = decimalField(fields, "cost").orElseThrow();
        FuelType fuelType = fuelTypeField(fields, vehicle);
        String fuelName = stringField(fields, "fuelName").orElse(null);
        TimelineEventResponse event = timelineEvents.createRefuelEvent(
                vehicle.getId(),
                new CreateRefuelEventRequest(
                        eventDateTime(userText),
                        "Заправка",
                        mileageKm,
                        liters,
                        cost,
                        fuelType,
                        fuelName,
                        null));
        return Optional.of(new AssistantDraft(refuelCreatedAnswer(event), null, event));
    }

    private Optional<AssistantDraft> createTripFromText(
            String userText,
            Vehicle vehicle,
            Map<String, Object> carriedFields) {
        Map<String, Object> fields = mergedFields(carriedFields, prefill(userText));
        fields.putIfAbsent("startMileageKm", vehicle.getMileageKm());
        firstInteger(userText, DISTANCE_PATTERN).ifPresent(distance ->
                fields.putIfAbsent("endMileageKm", vehicle.getMileageKm() + distance));
        durationMinutes(userText).ifPresent(duration ->
                fields.put("durationMinutes", duration));
        route(userText).ifPresent(route -> fields.put("route", route));
        List<String> errors = tripValidationErrors(fields, vehicle);
        if (!errors.isEmpty()) {
            return Optional.of(new AssistantDraft(missingOrInvalidAnswer("поездку", errors), pendingAction("TRIP", fields), null));
        }
        TimelineEventResponse event = timelineEvents.createTripEvent(
                vehicle.getId(),
                new CreateTripEventRequest(
                        eventDateTime(userText),
                        stringField(fields, "route").orElse("Поездка"),
                        integerField(fields, "startMileageKm").orElse(null),
                        integerField(fields, "endMileageKm").orElseThrow(),
                        stringField(fields, "route").orElse(null),
                        integerField(fields, "durationMinutes").orElseThrow()));
        return Optional.of(new AssistantDraft(tripCreatedAnswer(event), null, event));
    }

    private Optional<AssistantDraft> startTripFromChatMessage(String userText, ChatSession session, Vehicle vehicle) {
        TimelineEventResponse event = timelineEvents.startChatTrip(vehicle.getId(), session, OffsetDateTime.now(), userText);
        Map<String, Object> fields = new LinkedHashMap<>();
        fields.put("tripId", event.id().toString());
        return Optional.of(new AssistantDraft(
                tripStartedAnswer(event),
                pendingAction("TRIP", fields),
                event));
    }

    private Optional<AssistantDraft> endActiveTripFromChatMessage(String userText, ChatSession session, Vehicle vehicle) {
        return timelineEvents.activeChatTripId(session)
                .map(tripId -> updateLifecycleTripFromText(userText, vehicle, session, tripId, Map.of()))
                .orElseGet(() -> Optional.of(new AssistantDraft(
                        "\u041d\u0435 \u0432\u0438\u0436\u0443 \u0430\u043a\u0442\u0438\u0432\u043d\u043e\u0439 \u043f\u043e\u0435\u0437\u0434\u043a\u0438 \u0434\u043b\u044f \u0437\u0430\u0432\u0435\u0440\u0448\u0435\u043d\u0438\u044f. \u0421\u043d\u0430\u0447\u0430\u043b\u0430 \u043d\u0430\u0447\u043d\u0438 \u043f\u043e\u0435\u0437\u0434\u043a\u0443, \u0430 \u043f\u043e\u0442\u043e\u043c \u044f \u0441\u043e\u0445\u0440\u0430\u043d\u044e \u0432\u0440\u0435\u043c\u044f \u0444\u0438\u043d\u0438\u0448\u0430.",
                        null,
                        null)));
    }

    private Optional<AssistantDraft> updateLifecycleTripFromText(
            String userText,
            Vehicle vehicle,
            ChatSession session,
            UUID tripId,
            Map<String, Object> carriedFields) {
        Map<String, Object> fields = mergedFields(carriedFields, prefill(userText));
        firstInteger(userText, DISTANCE_PATTERN).ifPresent(distance -> fields.put("distanceKm", distance));
        durationMinutes(userText).ifPresent(duration -> fields.put("durationMinutes", duration));
        decimalField(fields, "liters").ifPresent(fuelLiters -> fields.put("fuelLiters", fuelLiters));
        OffsetDateTime endedAt = endsTripConversation(userText) || hasLifecycleCompletionFields(fields)
                ? OffsetDateTime.now()
                : null;
        TimelineEventResponse event = timelineEvents.updateChatTrip(
                vehicle.getId(),
                tripId,
                session,
                new TimelineEventService.TripUpdate(
                        endedAt,
                        integerField(fields, "distanceKm").orElse(null),
                        integerField(fields, "durationMinutes").orElse(null),
                        decimalField(fields, "fuelLiters").orElse(null),
                        userText));
        if (event.tripStatus() == ru.talkingshaha.backend.timeline.model.TripCompletionStatus.COMPLETE) {
            return Optional.of(new AssistantDraft(tripLifecycleCompletedAnswer(event), null, event));
        }
        Map<String, Object> nextFields = new LinkedHashMap<>(fields);
        nextFields.put("tripId", tripId.toString());
        return Optional.of(new AssistantDraft(tripLifecyclePartialAnswer(event), pendingAction("TRIP", nextFields), event));
    }

    private Optional<AssistantDraft> createMaintenanceFromText(
            String userText,
            Vehicle vehicle,
            Map<String, Object> carriedFields) {
        Map<String, Object> fields = mergedFields(carriedFields, prefill(userText));
        fields.putIfAbsent("mileageKm", vehicle.getMileageKm());
        MaintenanceDraft draft = maintenanceDraft(userText);
        draft.name().ifPresent(name -> fields.putIfAbsent("name", name));
        firstDecimal(userText, MONEY_PATTERN).ifPresent(cost -> fields.put("cost", cost));
        List<String> errors = maintenanceValidationErrors(fields, vehicle);
        if (!errors.isEmpty()) {
            return Optional.of(new AssistantDraft(missingOrInvalidAnswer("ремонт", errors), pendingAction("MAINTENANCE", fields), null));
        }
        String description = draft.description().orElse(userText);
        TimelineEventResponse event = timelineEvents.createMaintenanceEvent(
                vehicle.getId(),
                new CreateMaintenanceEventRequest(
                        eventDateTime(userText),
                        integerField(fields, "mileageKm").orElseThrow(),
                        stringField(fields, "name").orElseThrow(),
                        description,
                        decimalField(fields, "cost").orElse(null),
                        List.of()));
        return Optional.of(new AssistantDraft(maintenanceCreatedAnswer(event), null, event));
    }

    private ChatActionResponse action(ChatDecision decision, String userText) {
        Map<String, Object> prefill = prefill(userText);
        return switch (decision.intent()) {
            case OPEN_REFUEL_FORM -> new ChatActionResponse("OPEN_FORM", "REFUEL", null, prefill);
            case OPEN_TRIP_FORM -> new ChatActionResponse("OPEN_FORM", "TRIP", null, prefill);
            case OPEN_PART_FORM -> new ChatActionResponse("OPEN_FORM", "PART_REPLACEMENT", null, prefill);
            case OPEN_REPAIR_FORM -> new ChatActionResponse("OPEN_FORM", "MAINTENANCE", null, prefill);
            case ASK_ANALYTICS -> new ChatActionResponse("OPEN_SCREEN", null, "ANALYTICS", Map.of());
            case ASK_REPAIR_NEED -> new ChatActionResponse("OPEN_SCREEN", null, "MAINTENANCE_FORECAST", Map.of());
            case ASK_FUEL, CASUAL -> null;
            case ASK_STATUS -> new ChatActionResponse("OPEN_SCREEN", null, "DASHBOARD", Map.of());
            case UNCLEAR -> null;
        };
    }

    private Map<String, Object> prefill(String userText) {
        Map<String, Object> prefill = new LinkedHashMap<>();
        explicitMileage(userText).ifPresent(value -> prefill.put("mileageKm", value));
        firstDecimal(userText, LITERS_PATTERN).ifPresent(value -> prefill.put("liters", value));
        firstDecimal(userText, MONEY_PATTERN).ifPresent(value -> prefill.put("cost", value));
        fuelName(userText).ifPresent(value -> prefill.put("fuelName", value));
        explicitFuelType(userText).ifPresent(value -> prefill.put("fuelType", value.name()));
        return prefill;
    }

    private Optional<ChatActionResponse> latestPendingAction(ChatSession session) {
        return messages.findAllBySessionOrderByCreatedAtAsc(session).stream()
                .filter(message -> message.getRole() == ChatMessageRole.ASSISTANT)
                .reduce((first, second) -> second)
                .filter(message -> "PENDING_EVENT".equals(message.getActionType()))
                .map(message -> new ChatActionResponse(
                        message.getActionType(),
                        message.getActionForm(),
                        message.getActionScreen(),
                        prefillFromJson(message.getActionPrefill())));
    }

    private ChatActionResponse pendingAction(String form, Map<String, Object> fields) {
        return new ChatActionResponse("PENDING_EVENT", form, null, fields);
    }

    private boolean startsTripConversation(String userText) {
        String text = normalizedText(userText);
        boolean hasTrip = text.contains("trip") || text.contains("\u043f\u043e\u0435\u0437\u0434");
        return hasTrip && (text.contains("start")
                || text.contains("begin")
                || text.contains("\u043d\u0430\u0447")
                || text.contains("\u0441\u0442\u0430\u0440\u0442")
                || text.contains("\u043f\u043e\u0435\u0445\u0430\u043b"));
    }

    private boolean endsTripConversation(String userText) {
        String text = normalizedText(userText);
        boolean hasTrip = text.contains("trip") || text.contains("\u043f\u043e\u0435\u0437\u0434");
        return hasTrip && (text.contains("end")
                || text.contains("finish")
                || text.contains("complete")
                || text.contains("\u0437\u0430\u043a\u043e\u043d\u0447")
                || text.contains("\u0437\u0430\u0432\u0435\u0440\u0448")
                || text.contains("\u0444\u0438\u043d\u0438\u0448"));
    }

    private String normalizedText(String userText) {
        return userText == null ? "" : userText.toLowerCase(Locale.ROOT);
    }

    private Map<String, Object> mergedFields(Map<String, Object> first, Map<String, Object> second) {
        Map<String, Object> merged = new LinkedHashMap<>(first);
        second.forEach((key, value) -> {
            if (value != null) {
                merged.put(key, value);
            }
        });
        return merged;
    }

    private List<String> refuelValidationErrors(Map<String, Object> fields, Vehicle vehicle) {
        List<String> errors = new java.util.ArrayList<>();
        validateMileageField(fields, vehicle, errors);
        validatePositiveDecimal(fields, "liters", "литры", true, errors);
        validatePositiveDecimal(fields, "cost", "стоимость", true, errors);
        unsupportedFuelName(fields).ifPresent(value ->
                errors.add("тип топлива должен быть одним из: " + String.join(", ", SUPPORTED_FUEL_NAMES)));
        if (fuelTypeField(fields, vehicle) == null) {
            errors.add("нужно указать тип топлива");
        }
        return errors;
    }

    private List<String> tripValidationErrors(Map<String, Object> fields, Vehicle vehicle) {
        List<String> errors = new java.util.ArrayList<>();
        Optional<Integer> start = integerField(fields, "startMileageKm");
        Optional<Integer> end = integerField(fields, "endMileageKm");
        if (start.isEmpty()) {
            errors.add("нужен начальный пробег");
        } else {
            validateMileageValue(start.get(), vehicle, "начальный пробег", errors);
        }
        if (end.isEmpty()) {
            errors.add("нужен конечный пробег или дистанция поездки");
        } else {
            validateMileageValue(end.get(), vehicle, "конечный пробег", errors);
        }
        if (start.isPresent() && end.isPresent() && end.get() <= start.get()) {
            errors.add("конечный пробег должен быть больше начального");
        }
        validatePositiveInteger(fields, "durationMinutes", "длительность", true, errors);
        return errors;
    }

    private List<String> maintenanceValidationErrors(Map<String, Object> fields, Vehicle vehicle) {
        List<String> errors = new java.util.ArrayList<>();
        validateMileageField(fields, vehicle, errors);
        Optional<String> name = stringField(fields, "name");
        if (name.isEmpty() || name.get().isBlank()) {
            errors.add("нужно описание работы");
        } else if (name.get().length() > 255) {
            errors.add("описание работы должно быть не длиннее 255 символов");
        }
        validatePositiveDecimal(fields, "cost", "стоимость", false, errors);
        return errors;
    }

    private void validateMileageField(Map<String, Object> fields, Vehicle vehicle, List<String> errors) {
        Optional<Integer> mileage = integerField(fields, "mileageKm");
        if (mileage.isEmpty()) {
            errors.add("нужен текущий пробег");
            return;
        }
        validateMileageValue(mileage.get(), vehicle, "пробег", errors);
    }

    private void validateMileageValue(Integer mileage, Vehicle vehicle, String label, List<String> errors) {
        if (mileage <= 0) {
            errors.add(label + " должен быть положительным");
        }
        if (mileage < vehicle.getMileageKm()) {
            errors.add(label + " должен быть не меньше текущего пробега " + vehicle.getMileageKm() + " км");
        }
    }

    private void validatePositiveDecimal(
            Map<String, Object> fields,
            String key,
            String label,
            boolean required,
            List<String> errors) {
        Optional<BigDecimal> value = decimalField(fields, key);
        if (value.isEmpty()) {
            if (required) {
                errors.add("нужно указать " + label);
            }
            return;
        }
        if (value.get().compareTo(BigDecimal.ZERO) <= 0) {
            errors.add(label + " должна быть больше 0");
        }
    }

    private void validatePositiveInteger(
            Map<String, Object> fields,
            String key,
            String label,
            boolean required,
            List<String> errors) {
        Optional<Integer> value = integerField(fields, key);
        if (value.isEmpty()) {
            if (required) {
                errors.add("нужно указать " + label);
            }
            return;
        }
        if (value.get() <= 0) {
            errors.add(label + " должна быть больше 0");
        }
    }

    private Optional<Integer> integerField(Map<String, Object> fields, String key) {
        Object value = fields.get(key);
        if (value instanceof Integer integer) {
            return Optional.of(integer);
        }
        if (value instanceof Number number) {
            return Optional.of(number.intValue());
        }
        if (value instanceof String string && !string.isBlank()) {
            try {
                return Optional.of(Integer.parseInt(string));
            } catch (NumberFormatException ignored) {
                return Optional.empty();
            }
        }
        return Optional.empty();
    }

    private Optional<UUID> uuidField(Map<String, Object> fields, String key) {
        Object value = fields.get(key);
        if (value instanceof UUID uuid) {
            return Optional.of(uuid);
        }
        if (value instanceof String string && !string.isBlank()) {
            try {
                return Optional.of(UUID.fromString(string));
            } catch (IllegalArgumentException ignored) {
                return Optional.empty();
            }
        }
        return Optional.empty();
    }

    private boolean hasLifecycleCompletionFields(Map<String, Object> fields) {
        return integerField(fields, "distanceKm").isPresent()
                && integerField(fields, "durationMinutes").isPresent()
                && decimalField(fields, "fuelLiters").isPresent();
    }

    private Optional<BigDecimal> decimalField(Map<String, Object> fields, String key) {
        Object value = fields.get(key);
        if (value instanceof BigDecimal decimal) {
            return Optional.of(decimal);
        }
        if (value instanceof Number number) {
            return Optional.of(BigDecimal.valueOf(number.doubleValue()));
        }
        if (value instanceof String string && !string.isBlank()) {
            try {
                return Optional.of(new BigDecimal(string.replace(',', '.')));
            } catch (NumberFormatException ignored) {
                return Optional.empty();
            }
        }
        return Optional.empty();
    }

    private Optional<String> stringField(Map<String, Object> fields, String key) {
        Object value = fields.get(key);
        return value instanceof String string && !string.isBlank()
                ? Optional.of(string)
                : Optional.empty();
    }

    private FuelType fuelTypeField(Map<String, Object> fields, Vehicle vehicle) {
        Optional<String> raw = stringField(fields, "fuelType");
        if (raw.isPresent()) {
            try {
                return FuelType.valueOf(raw.get());
            } catch (IllegalArgumentException ignored) {
                return vehicle != null && vehicle.getFuelType() != null ? vehicle.getFuelType() : FuelType.GASOLINE;
            }
        }
        return vehicle != null && vehicle.getFuelType() != null ? vehicle.getFuelType() : FuelType.GASOLINE;
    }

    private String missingOrInvalidAnswer(String eventName, List<String> errors) {
        return "Хочу записать " + eventName + " в свою историю, но нужно уточнить данные: "
                + String.join("; ", errors)
                + ". Пришли недостающие или исправленные значения одним сообщением.";
    }

    private Optional<Integer> explicitMileage(String userText) {
        return firstInteger(userText, MILEAGE_PATTERN);
    }

    private Optional<Integer> firstInteger(String userText, Pattern pattern) {
        Matcher matcher = pattern.matcher(userText);
        return matcher.find() ? Optional.of(Integer.parseInt(matcher.group(1))) : Optional.empty();
    }

    private Optional<BigDecimal> firstDecimal(String userText, Pattern pattern) {
        Matcher matcher = pattern.matcher(userText);
        return matcher.find()
                ? Optional.of(new BigDecimal(matcher.group(1).replace(',', '.')))
                : Optional.empty();
    }

    private Optional<String> fuelName(String userText) {
        Matcher matcher = FUEL_GRADE_PATTERN.matcher(userText);
        if (matcher.find()) {
            return Optional.of(supportedGasolineName(matcher.group(1)).orElse("UNSUPPORTED:" + matcher.group(1)));
        }
        String lower = userText.toLowerCase();
        if (lower.contains("diesel") || lower.contains("диз")) {
            return Optional.of("Diesel");
        }
        return Optional.empty();
    }

    private Optional<String> shortFuelName(String userText) {
        String normalized = userText.trim().toLowerCase();
        if (normalized.matches("(?:ai[-\\s]?)?\\d{2,3}(?:[-\\s]?(?:й|м))?")) {
            String grade = normalized.replaceAll("\\D", "");
            return Optional.of(supportedGasolineName(grade).orElse("UNSUPPORTED:" + grade));
        }
        if (normalized.equals("diesel") || normalized.equals("дизель")) {
            return Optional.of("Diesel");
        }
        return Optional.empty();
    }

    private Optional<String> supportedGasolineName(String grade) {
        return switch (grade) {
            case "92" -> Optional.of("92 octane");
            case "95" -> Optional.of("95 octane");
            case "98" -> Optional.of("98 octane");
            default -> Optional.empty();
        };
    }

    private Optional<String> unsupportedFuelName(Map<String, Object> fields) {
        return stringField(fields, "fuelName")
                .filter(value -> !SUPPORTED_FUEL_NAMES.contains(value));
    }

    private FuelType fuelType(String userText, Vehicle vehicle) {
        Optional<FuelType> explicit = explicitFuelType(userText);
        if (explicit.isPresent()) {
            return explicit.get();
        }
        if (vehicle != null && vehicle.getFuelType() != null) {
            return vehicle.getFuelType();
        }
        return FuelType.GASOLINE;
    }

    private Optional<FuelType> explicitFuelType(String userText) {
        String lower = userText.toLowerCase();
        if (lower.contains("diesel") || lower.contains("диз")) {
            return Optional.of(FuelType.DIESEL);
        }
        if (lower.contains("electric") || lower.contains("элект")) {
            return Optional.of(FuelType.ELECTRIC);
        }
        if (lower.contains("gas") || lower.contains("petrol") || lower.contains("бенз")) {
            return Optional.of(FuelType.GASOLINE);
        }
        return Optional.empty();
    }

    private Optional<String> route(String userText) {
        Matcher matcher = Pattern.compile(
                        "(?:from|из|от)\\s+(.+?)\\s+(?:to|до|в)\\s+(.+?)(?=,?\\s+(?:за|for)|\\s+\\d|$)",
                        Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE)
                .matcher(userText);
        if (matcher.find()) {
            String from = cleanRoutePlace(matcher.group(1));
            String to = cleanRoutePlace(matcher.group(2));
            if (!from.isBlank() && !to.isBlank()) {
                return Optional.of(from + " -> " + to);
            }
        }
        return Optional.empty();
    }

    private String cleanRoutePlace(String place) {
        String cleaned = place
                .replaceAll("(?iu),?\\s*(?:за|for)(?:\\s+.*)?$", " ")
                .replaceAll("(?iu)\\s+проехал[а]?\\s+.*", " ")
                .replaceAll("(?iu)\\s+drove\\s+.*", " ")
                .replaceAll("[\\p{Punct}&&[^-]]+$", " ")
                .replaceAll("\\s+", " ")
                .strip();
        return normalizeRoutePlace(cleaned);
    }

    private String normalizeRoutePlace(String place) {
        if (place.split("\\s+").length == 1 && place.toLowerCase(Locale.ROOT).endsWith("иса")) {
            return place.substring(0, place.length() - 1);
        }
        return place;
    }

    private Optional<Integer> durationMinutes(String userText) {
        Optional<Integer> explicitMinutes = firstInteger(userText, DURATION_PATTERN);
        if (explicitMinutes.isPresent()) {
            return explicitMinutes;
        }
        return firstInteger(userText, HOURS_PATTERN).map(hours -> hours * 60);
    }

    private OffsetDateTime eventDateTime(String userText) {
        OffsetDateTime now = OffsetDateTime.now();
        String text = normalizedText(userText);
        if (text.contains("позавчера")) {
            return now.minusDays(2);
        }
        if (text.contains("вчера") || text.contains("yesterday")) {
            return now.minusDays(1);
        }
        Optional<LocalDate> explicitDate = explicitEventDate(text, now.toLocalDate());
        if (explicitDate.isPresent()) {
            return now.withYear(explicitDate.get().getYear())
                    .withMonth(explicitDate.get().getMonthValue())
                    .withDayOfMonth(explicitDate.get().getDayOfMonth());
        }
        return now;
    }

    private Optional<LocalDate> explicitEventDate(String text, LocalDate today) {
        Matcher textDate = TEXT_DATE_PATTERN.matcher(text);
        if (textDate.find()) {
            return localDate(
                    parseInteger(textDate.group(1)),
                    monthNumber(textDate.group(2)).orElse(null),
                    year(textDate.group(3), today),
                    today);
        }

        Matcher numericDate = NUMERIC_DATE_PATTERN.matcher(text);
        if (numericDate.find()) {
            return localDate(
                    parseInteger(numericDate.group(1)),
                    parseInteger(numericDate.group(2)),
                    year(numericDate.group(3), today),
                    today);
        }

        return Optional.empty();
    }

    private Optional<LocalDate> localDate(Integer day, Integer month, Integer year, LocalDate today) {
        if (day == null || month == null || year == null) {
            return Optional.empty();
        }
        try {
            LocalDate date = LocalDate.of(year, month, day);
            return Optional.of(date.isAfter(today) ? date.minusYears(1) : date);
        } catch (RuntimeException ignored) {
            return Optional.empty();
        }
    }

    private Integer parseInteger(String value) {
        return value == null || value.isBlank() ? null : Integer.parseInt(value);
    }

    private Integer year(String value, LocalDate today) {
        if (value == null || value.isBlank()) {
            return today.getYear();
        }
        int year = Integer.parseInt(value);
        return year < 100 ? 2000 + year : year;
    }

    private Optional<Integer> monthNumber(String month) {
        return switch (month.toLowerCase(Locale.ROOT)) {
            case "января", "январь" -> Optional.of(1);
            case "февраля", "февраль" -> Optional.of(2);
            case "марта", "март" -> Optional.of(3);
            case "апреля", "апрель" -> Optional.of(4);
            case "мая", "май" -> Optional.of(5);
            case "июня", "июнь" -> Optional.of(6);
            case "июля", "июль" -> Optional.of(7);
            case "августа", "август" -> Optional.of(8);
            case "сентября", "сентябрь" -> Optional.of(9);
            case "октября", "октябрь" -> Optional.of(10);
            case "ноября", "ноябрь" -> Optional.of(11);
            case "декабря", "декабрь" -> Optional.of(12);
            default -> Optional.empty();
        };
    }

    private boolean asksForRequiredFields(String userText) {
        String lower = userText.toLowerCase();
        return lower.contains("какие данные")
                || lower.contains("что нужно")
                || lower.contains("что ввести")
                || lower.contains("какие поля")
                || lower.contains("what data")
                || lower.contains("what fields")
                || lower.contains("what should i enter");
    }

    private Optional<String> maintenanceName(String userText) {
        String stripped = maintenanceWorkText(userText);
        if (stripped.isBlank() || stripped.length() < 4 || stripped.equals("записать") || stripped.equals("добавить")) {
            return Optional.empty();
        }
        return Optional.of(replacementParts(stripped)
                .map(part -> replacementTitle(part, stripped))
                .orElse(stripped.substring(0, Math.min(120, stripped.length()))));
    }

    private MaintenanceDraft maintenanceDraft(String userText) {
        String workText = maintenanceWorkText(userText);
        Optional<String> name = maintenanceName(userText);
        Optional<String> parts = replacementParts(workText);
        String description = workText.isBlank() ? userText : workText;
        if (parts.isPresent()) {
            description = description + "\nReplaced parts: " + parts.get();
        }
        return new MaintenanceDraft(name, Optional.of(description));
    }

    private String maintenanceWorkText(String userText) {
        return removeExplicitDates(userText)
                .replaceAll("(?iu)(?:на\\s+)?пробег(?:е)?\\D{0,12}-?\\d+\\s*(?:km|км)?", " ")
                .replaceAll("(?iu)(?:стоимость|цена|стоил[ао]?|cost)\\D{0,12}-?\\d+(?:[.,]\\d+)?\\s*(?:rub|ruble|rubles|₽|р|руб|рублей|рубля).*", " ")
                .replaceAll("(?iu)(?:^|\\s)за\\s+-?\\d+(?:[.,]\\d+)?\\s*(?:rub|ruble|rubles|₽|р|руб|рублей|рубля).*", " ")
                .toLowerCase()
                .replaceAll("(?iu)(^|\\s)(я|i)(?=\\s|$)", " ")
                .replaceAll("(?iu)(^|\\s)(сегодня|вчера|завтра|today|yesterday|tomorrow|ещё|еще|сейчас)(?=\\s|$)", " ")
                .replaceAll("(?iu)(^|\\s)(хочу|want|need|нужно|надо)(?=\\s|$)", " ")
                .replaceAll("(?iu)add repair|record repair|new repair|repair record", " ")
                .replaceAll("(?iu)добавить ремонт|записать ремонт|новый ремонт|запись ремонта", " ")
                .replaceAll("(?iu)ремонт|repair|maintenance|обслуживание|сервис", " ")
                .replaceAll("(?iu)какие данные.*|что нужно.*|что ввести.*|какие поля.*|what data.*|what fields.*", " ")
                .replaceAll("[\\p{Punct}&&[^-]]+", " ")
                .replaceAll("\\s+", " ")
                .strip();
    }

    private String removeExplicitDates(String text) {
        return NUMERIC_DATE_PATTERN.matcher(TEXT_DATE_PATTERN.matcher(text).replaceAll(" ")).replaceAll(" ");
    }

    private Optional<String> replacementParts(String workText) {
        Matcher matcher = Pattern.compile(
                        "(?iu)(?:поменял[аи]?|заменил[аи]?|менял[аи]?|замена|changed|replaced|replace)\\s+(.+)")
                .matcher(workText);
        if (!matcher.find()) {
            return Optional.empty();
        }
        String parts = matcher.group(1)
                .replaceAll("(?iu)\\s+(?:на|for|with)\\s+.*", " ")
                .replaceAll("\\s+", " ")
                .strip();
        return parts.isBlank() ? Optional.empty() : Optional.of(parts.substring(0, Math.min(120, parts.length())));
    }

    private String replacementTitle(String parts, String fallback) {
        if (parts.chars().anyMatch(ch -> Character.UnicodeBlock.of(ch) == Character.UnicodeBlock.CYRILLIC)) {
            return "замена " + replacementTitleParts(parts);
        }
        return "Replacement: " + parts;
    }

    private String replacementTitleParts(String parts) {
        return List.of(parts.split("\\s+")).stream()
                .map(this::genitivePartName)
                .reduce((left, right) -> left + " " + right)
                .orElse(parts)
                .strip();
    }

    private String genitivePartName(String part) {
        return switch (part) {
            case "двигатель" -> "двигателя";
            case "мотор" -> "мотора";
            case "фильтр" -> "фильтра";
            case "аккумулятор" -> "аккумулятора";
            case "ремень" -> "ремня";
            case "масло" -> "масла";
            case "свечи" -> "свечей";
            case "колодки" -> "колодок";
            default -> part;
        };
    }

    private String refuelRequiredFieldsAnswer() {
        return "Для заправки мне нужны литры, стоимость, тип топлива и пробег. Если пробег не укажешь, возьму мой текущий.";
    }

    private String tripRequiredFieldsAnswer() {
        return "Для поездки мне нужны дистанция или конечный пробег и длительность. Начальный пробег могу взять из моего текущего пробега.";
    }

    private String maintenanceRequiredFieldsAnswer() {
        return "Для ремонта пришли, что сделали со мной, пробег и стоимость, если она есть. Без описания работы я запись не создам.";
    }

    private String refuelCreatedAnswer(TimelineEventResponse event) {
        String fuel = event.fuelName() == null ? event.fuelType().name() : event.fuelName();
        String cost = event.cost() == null ? "без стоимости" : "за " + event.cost() + " RUB";
        return "Записала себе заправку: %s л %s, %s. Пробег сейчас %s км."
                .formatted(event.liters(), fuel, cost, event.mileageKm());
    }

    private String tripCreatedAnswer(TimelineEventResponse event) {
        return "Записала поездку: %s км за %s минут. Мой текущий пробег теперь %s км."
                .formatted(event.distanceKm(), event.durationMinutes(), event.endMileageKm());
    }

    private String maintenanceCreatedAnswer(TimelineEventResponse event) {
        return "Записала ремонт в свою историю: %s, пробег %s км."
                .formatted(event.name(), event.mileageKm());
    }

    private String tripStartedAnswer(TimelineEventResponse event) {
        return "\u041f\u043e\u0435\u0437\u0434\u043a\u0443 \u043d\u0430\u0447\u0430\u043b\u0430 \u0438 \u0441\u043e\u0445\u0440\u0430\u043d\u0438\u043b\u0430 \u0441\u0442\u0430\u0440\u0442. \u041a\u043e\u0433\u0434\u0430 \u0437\u0430\u043a\u043e\u043d\u0447\u0438\u0448\u044c, \u043d\u0430\u043f\u0438\u0448\u0438 \u0441\u044e\u0434\u0430 \u0434\u0438\u0441\u0442\u0430\u043d\u0446\u0438\u044e, \u0434\u043b\u0438\u0442\u0435\u043b\u044c\u043d\u043e\u0441\u0442\u044c \u0438 \u0440\u0430\u0441\u0445\u043e\u0434 \u0442\u043e\u043f\u043b\u0438\u0432\u0430.";
    }

    private String tripLifecyclePartialAnswer(TimelineEventResponse event) {
        return "\u0421\u043e\u0445\u0440\u0430\u043d\u0438\u043b\u0430 \u043f\u043e\u0435\u0437\u0434\u043a\u0443 \u0447\u0430\u0441\u0442\u0438\u0447\u043d\u043e. \u041f\u0440\u0438\u0448\u043b\u0438 \u043d\u0435\u0434\u043e\u0441\u0442\u0430\u044e\u0449\u0438\u0435 \u0434\u0430\u043d\u043d\u044b\u0435: \u0434\u0438\u0441\u0442\u0430\u043d\u0446\u0438\u044e, \u0434\u043b\u0438\u0442\u0435\u043b\u044c\u043d\u043e\u0441\u0442\u044c \u0438\u043b\u0438 \u0440\u0430\u0441\u0445\u043e\u0434 \u0442\u043e\u043f\u043b\u0438\u0432\u0430.";
    }

    private String tripLifecycleCompletedAnswer(TimelineEventResponse event) {
        return "\u041f\u043e\u0435\u0437\u0434\u043a\u0443 \u0437\u0430\u0432\u0435\u0440\u0448\u0438\u043b\u0430: %s \u043a\u043c \u0437\u0430 %s \u043c\u0438\u043d\u0443\u0442, \u0440\u0430\u0441\u0445\u043e\u0434 \u0442\u043e\u043f\u043b\u0438\u0432\u0430 %s \u043b."
                .formatted(event.distanceKm(), event.durationMinutes(), decimal(event.fuelLiters()));
    }

    private String contextForDecision(
            ChatDecision decision,
            VehicleDashboardResponse dashboard,
            AnalyticsOverviewResponse analyticsOverview,
            ChatActionResponse action) {
        StringBuilder builder = new StringBuilder(context(dashboard, analyticsOverview));
        builder.append("\nDecision: ").append(decision.intent());
        builder.append("\nAction: ").append(action == null ? "none" : action);
        if (decision.intent() == ChatIntent.ASK_ANALYTICS && !analyticsOverview.hasData()) {
            builder.append("\nThere is not enough analytics data for a grounded answer.");
        }
        if (decision.intent() == ChatIntent.ASK_REPAIR_NEED && dashboard.maintenanceForecast().parts().isEmpty()) {
            builder.append("\nThere is not enough parts data for a grounded repair forecast.");
        }
        return builder.toString();
    }

    private String context(VehicleDashboardResponse dashboard, AnalyticsOverviewResponse analyticsOverview) {
        var vehicle = dashboard.vehicle();
        var forecast = dashboard.maintenanceForecast();
        StringBuilder builder = new StringBuilder();
        builder.append("Vehicle: ")
                .append(vehicle.brand()).append(" ").append(vehicle.model())
                .append(", year ").append(vehicle.productionYear())
                .append(", mileage ").append(vehicle.mileageKm()).append(" km")
                .append(", fuel ").append(vehicle.fuelType()).append(".\n");
        builder.append("Maintenance forecast: overallStatus=")
                .append(forecast.overallStatus())
                .append(", nextServiceInKm=")
                .append(forecast.nextServiceInKm())
                .append(".\n");
        builder.append("Parts: ");
        if (forecast.parts().isEmpty()) {
            builder.append("none.");
        } else {
            builder.append(forecast.parts().stream()
                    .sorted(Comparator.comparing(part -> part.remainingKm() == null ? Integer.MAX_VALUE : part.remainingKm()))
                    .map(part -> "%s status=%s remainingKm=%s remainingPercent=%s"
                            .formatted(part.name(), part.status(), part.remainingKm(), part.remainingPercent()))
                    .toList());
        }
        builder.append("\nAnalytics: hasData=").append(analyticsOverview.hasData())
                .append(", totalExpenses=").append(money(analyticsOverview.totalExpenses()))
                .append(" ").append(analyticsOverview.currency())
                .append(", costPerKm=").append(analyticsOverview.costPerKilometer().costPerKm())
                .append(", totalTripKm=").append(analyticsOverview.costPerKilometer().totalKm())
                .append(", fuelLiters=").append(analyticsOverview.fuel().totalLiters())
                .append(", fuelConsumptionPer100Km=")
                .append(analyticsOverview.fuel().averageConsumptionLitersPer100Km())
                .append(", events=").append(analyticsOverview.historyAnalysis().eventCount())
                .append(".");
        return builder.toString();
    }

    private String templateAnswer(
            String userText,
            ChatDecision decision,
            VehicleDashboardResponse dashboard,
            AnalyticsOverviewResponse analyticsOverview,
            ChatActionResponse action) {
        return switch (decision.intent()) {
            case ASK_ANALYTICS -> analyticsAnswer(decision.language(), analyticsOverview);
            case OPEN_REFUEL_FORM, OPEN_TRIP_FORM, OPEN_PART_FORM, OPEN_REPAIR_FORM -> formAnswer(decision.language(), action);
            case ASK_REPAIR_NEED -> repairAnswer(decision.language(), dashboard);
            case ASK_FUEL -> fuelAnswer(decision.language(), analyticsOverview);
            case CASUAL -> casualAnswer(decision.language(), dashboard, userText);
            case ASK_STATUS -> statusAnswer(decision.language(), dashboard);
            case UNCLEAR -> unclearAnswer(decision.language());
        };
    }

    private String analyticsAnswer(ChatLanguage language, AnalyticsOverviewResponse overview) {
        if (!overview.hasData()) {
            return language == ChatLanguage.RU
                    ? "Я пока не накопила достаточно истории для точной аналитики. Добавь мне поездки, заправки или обслуживание, и я смогу честно посчитать расходы."
                    : "I do not have enough history for accurate analytics yet. Add trips, refuels, or maintenance records, and I can calculate my expenses properly.";
        }
        String text = "My expenses are %s %s, cost per km is %s, and fuel consumption is %s L/100 km. You can open analytics for more details."
                .formatted(money(overview.totalExpenses()), overview.currency(),
                        decimal(overview.costPerKilometer().costPerKm()),
                        decimal(overview.fuel().averageConsumptionLitersPer100Km()));
        return language == ChatLanguage.RU
                ? "По моей истории расходы: %s %s, стоимость 1 км: %s, расход топлива: %s л/100 км. В аналитике можно посмотреть подробнее."
                        .formatted(money(overview.totalExpenses()), overview.currency(),
                                decimal(overview.costPerKilometer().costPerKm()),
                                decimal(overview.fuel().averageConsumptionLitersPer100Km()))
                : text;
    }

    private String formAnswer(ChatLanguage language, ChatActionResponse action) {
        String form = action == null ? "the form" : action.form();
        return language == ChatLanguage.RU
                ? "Похоже, это нужно записать в мою историю. Я могу открыть форму %s и передать туда найденные данные."
                        .formatted(form)
                : "This looks like something to record in my history. I can open the %s form and pass the extracted data."
                        .formatted(form);
    }

    private String repairAnswer(ChatLanguage language, VehicleDashboardResponse dashboard) {
        List<PartResponse> parts = dashboard.maintenanceForecast().parts();
        if (parts.isEmpty()) {
            return language == ChatLanguage.RU
                    ? "Мне пока не хватает данных по деталям и обслуживанию, чтобы честно оценить ремонт. Добавь их, и я подскажу, что у меня просится в сервис первым."
                    : "I do not have enough parts or maintenance data yet. Add them, and I can tell you what in me needs service first.";
        }
        PartResponse urgent = parts.stream()
                .min(Comparator.comparing(part -> part.remainingKm() == null ? Integer.MAX_VALUE : part.remainingKm()))
                .orElseThrow();
        boolean warning = urgent.status() == PartStatus.CRITICAL || urgent.status() == PartStatus.ATTENTION;
        if (language == ChatLanguage.RU) {
            return "Мой общий статус: %s. Больше всего внимания просит %s: осталось %s км (%s%%), статус %s. %s В прогнозе обслуживания есть весь список."
                    .formatted(dashboard.maintenanceForecast().overallStatus(), urgent.name(), urgent.remainingKm(),
                            urgent.remainingPercent(), urgent.status(),
                            warning ? "Лучше запланировать обслуживание." : "Срочного ремонта не предвидится.");
        }
        return "My overall status is %s. The part that needs the most attention is %s: %s km left (%s%%), status %s. %s Open the maintenance forecast to see the full report."
                .formatted(dashboard.maintenanceForecast().overallStatus(), urgent.name(), urgent.remainingKm(),
                        urgent.remainingPercent(), urgent.status(),
                        warning ? "Plan maintenance soon." : "No urgent repair is visible.");
    }

    private String statusAnswer(ChatLanguage language, VehicleDashboardResponse dashboard) {
        return language == ChatLanguage.RU
                ? "У меня сейчас %s км пробега, статус обслуживания: %s, ближайший сервис через %s км."
                        .formatted(dashboard.vehicle().mileageKm(),
                                dashboard.maintenanceForecast().overallStatus(),
                                dashboard.maintenanceForecast().nextServiceInKm())
                : "My current mileage is %s km, maintenance status is %s, and next service is in %s km."
                        .formatted(dashboard.vehicle().mileageKm(),
                                dashboard.maintenanceForecast().overallStatus(),
                                dashboard.maintenanceForecast().nextServiceInKm());
    }

    private String fuelAnswer(ChatLanguage language, AnalyticsOverviewResponse overview) {
        if (!overview.hasData() || overview.fuel().totalLiters().compareTo(BigDecimal.ZERO) == 0) {
            return language == ChatLanguage.RU
                    ? "Я пока не вижу достаточно данных по своему топливу. Добавь мне хотя бы одну заправку и поездку, и я увереннее расскажу про расход."
                    : "I do not have enough fuel data yet. Add at least one refuel and trip, and I can talk about my consumption more confidently.";
        }
        return language == ChatLanguage.RU
                ? "По топливу в моей истории вижу %s л и средний расход %s л/100 км. Живого датчика бака у меня тут нет, поэтому точный остаток я не выдумываю."
                        .formatted(decimal(overview.fuel().totalLiters()), decimal(overview.fuel().averageConsumptionLitersPer100Km()))
                : "I can see %s L in my fuel history and an average consumption of %s L/100 km. I do not have a live tank sensor here, so I will not invent the exact remaining fuel."
                        .formatted(decimal(overview.fuel().totalLiters()), decimal(overview.fuel().averageConsumptionLitersPer100Km()));
    }

    private String casualAnswer(ChatLanguage language, VehicleDashboardResponse dashboard, String userText) {
        boolean greeted = userGreeted(userText);
        if (language == ChatLanguage.RU) {
            String prefix = greeted ? "Привет! " : "";
            return prefix + "Я тут, на связи. Сейчас у меня %s км пробега, статус обслуживания: %s."
                    .formatted(dashboard.vehicle().mileageKm(), dashboard.maintenanceForecast().overallStatus());
        }
        String prefix = greeted ? "Hi! " : "";
        return prefix + "I am here and online. My current mileage is %s km, and my maintenance status is %s."
                .formatted(dashboard.vehicle().mileageKm(), dashboard.maintenanceForecast().overallStatus());
    }

    private String polishAssistantText(String text, String userText, ChatLanguage language) {
        String polished = text
                .replaceAll("(?iu),?\\s*\\bхозяин\\b,?", "")
                .replaceAll("(?iu),?\\s*\\b(owner|master)\\b,?", "")
                .replaceAll("\\s{2,}", " ")
                .strip();
        if (!userGreeted(userText)) {
            polished = stripLeadingGreeting(polished, language);
        }
        return polished;
    }

    private String stripLeadingGreeting(String text, ChatLanguage language) {
        String stripped = language == ChatLanguage.RU
                ? text.replaceFirst("(?iu)^\\s*(привет|здравствуй|здравствуйте|добрый день)[!,.\\s]+", "")
                : text.replaceFirst("(?iu)^\\s*(hi|hello|hey)[!,.\\s]+", "");
        return stripped.strip();
    }

    private boolean userGreeted(String userText) {
        String text = normalizedText(userText);
        return text.matches("(?su).*\\b(hi|hello|hey|привет|здравствуй|здравствуйте|добрый день)\\b.*");
    }

    private String unclearAnswer(ChatLanguage language) {
        return language == ChatLanguage.RU
                ? "Я не до конца поняла, что ты хочешь сделать. Можешь спросить про мои расходы, состояние, топливо или сказать, какую заправку, поездку или ремонт записать."
                : "I did not fully understand that. You can ask about my expenses, condition, fuel, or tell me what refuel, trip, or repair to record.";
    }

    private String money(BigDecimal value) {
        return decimal(value);
    }

    private String decimal(BigDecimal value) {
        return value == null ? "0" : value.stripTrailingZeros().toPlainString();
    }

    private ChatSession getOrCreateSession(Vehicle vehicle, ChatLanguage language) {
        return sessions.findByVehicle(vehicle).orElseGet(() -> {
            ChatSession session = new ChatSession();
            session.setVehicle(vehicle);
            session.setCreatedAt(OffsetDateTime.now());
            ChatSession saved = sessions.save(session);
            saveMessage(saved, ChatMessageRole.ASSISTANT, initialMessage(language));
            return saved;
        });
    }

    private String initialMessage(ChatLanguage language) {
        return language == ChatLanguage.RU
                ? "Привет! Я твоя машина, я на связи."
                : "Hi! I am your car, and I am ready to chat.";
    }

    private ChatMessage saveMessage(ChatSession session, ChatMessageRole role, String text) {
        return saveMessage(session, role, text, null);
    }

    private ChatMessage saveMessage(ChatSession session, ChatMessageRole role, String text, ChatActionResponse action) {
        ChatMessage message = new ChatMessage();
        message.setSession(session);
        message.setRole(role);
        message.setText(text);
        message.setCreatedAt(OffsetDateTime.now());
        applyAction(message, action);
        return messages.save(message);
    }

    private List<String> quickQuestions(List<ChatMessageResponse> history, ChatLanguage fallbackLanguage) {
        ChatLanguage language = history.stream()
                .filter(message -> message.role() == ChatMessageRole.USER)
                .reduce((first, second) -> second)
                .map(message -> message.text().chars()
                        .anyMatch(ch -> Character.UnicodeBlock.of(ch) == Character.UnicodeBlock.CYRILLIC)
                        ? ChatLanguage.RU
                        : ChatLanguage.EN)
                .orElse(fallbackLanguage);
        return language == ChatLanguage.RU
                ? List.of("Состояние авто", "Какие расходы за всё время?", "Что может сломаться скоро?")
                : List.of("Vehicle status", "What are my total expenses?", "What can break soon?");
    }

    private ChatMessageResponse toResponse(ChatMessage message) {
        return new ChatMessageResponse(
                message.getId(),
                message.getRole(),
                message.getText(),
                message.getCreatedAt(),
                actionFromMessage(message));
    }

    private void applyAction(ChatMessage message, ChatActionResponse action) {
        if (action == null) {
            return;
        }

        message.setActionType(action.type());
        message.setActionForm(action.form());
        message.setActionScreen(action.screen());
        message.setActionPrefill(prefillToJson(action.prefill()));
    }

    private ChatActionResponse actionFromMessage(ChatMessage message) {
        if (message.getActionType() == null || message.getActionType().isBlank()) {
            return null;
        }
        if ("PENDING_EVENT".equals(message.getActionType())) {
            return null;
        }

        return new ChatActionResponse(
                message.getActionType(),
                message.getActionForm(),
                message.getActionScreen(),
                prefillFromJson(message.getActionPrefill()));
    }

    private String prefillToJson(Map<String, Object> prefill) {
        if (prefill == null || prefill.isEmpty()) {
            return "{}";
        }

        try {
            return objectMapper.writeValueAsString(prefill);
        } catch (JsonProcessingException exception) {
            return "{}";
        }
    }

    private Map<String, Object> prefillFromJson(String json) {
        if (json == null || json.isBlank()) {
            return Map.of();
        }

        try {
            return objectMapper.readValue(json, new TypeReference<>() {});
        } catch (JsonProcessingException exception) {
            return Map.of();
        }
    }

    private record AssistantDraft(String text, ChatActionResponse action, TimelineEventResponse createdEvent) {
    }

    private record MaintenanceDraft(Optional<String> name, Optional<String> description) {
    }
}
