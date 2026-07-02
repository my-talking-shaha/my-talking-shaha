package ru.talkingshaha.backend.chat.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
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
    public SendMessageResponse send(UUID vehicleId, SendMessageRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        ChatSession session = getOrCreateSession(vehicle, ChatLanguage.EN);
        ChatMessage userMessage = saveMessage(session, ChatMessageRole.USER, request.text());

        VehicleDashboardResponse dashboard = vehicles.dashboard(vehicleId);
        AnalyticsOverviewResponse analyticsOverview = analytics.overview(vehicleId, AnalyticsPeriod.ALL_TIME);
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
                .orElseGet(() -> templateAnswer(decision, dashboard, analyticsOverview, action));
        return new AssistantDraft(text, action, null);
    }

    private Optional<AssistantDraft> autoCreateEvent(
            String userText,
            ChatDecision decision,
            ChatSession session,
            Vehicle vehicle) {
        try {
            Optional<ChatActionResponse> pending = latestPendingAction(session);
            if (pending.isPresent()) {
                return continuePendingEvent(userText, pending.get(), vehicle);
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

    private Optional<AssistantDraft> continuePendingEvent(String userText, ChatActionResponse pending, Vehicle vehicle) {
        Map<String, Object> merged = new LinkedHashMap<>(pending.prefill());
        Map<String, Object> newFields = prefill(userText);
        if ("REFUEL".equals(pending.form())) {
            shortFuelName(userText).ifPresent(value -> newFields.put("fuelName", value));
        }
        merged.putAll(newFields);
        return switch (pending.form()) {
            case "REFUEL" -> createRefuelFromText(userText, vehicle, merged);
            case "TRIP" -> createTripFromText(userText, vehicle, merged);
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
                        OffsetDateTime.now(),
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
        firstInteger(userText, DURATION_PATTERN).ifPresent(duration ->
                fields.put("durationMinutes", duration));
        route(userText).ifPresent(route -> fields.put("route", route));
        List<String> errors = tripValidationErrors(fields, vehicle);
        if (!errors.isEmpty()) {
            return Optional.of(new AssistantDraft(missingOrInvalidAnswer("поездку", errors), pendingAction("TRIP", fields), null));
        }
        TimelineEventResponse event = timelineEvents.createTripEvent(
                vehicle.getId(),
                new CreateTripEventRequest(
                        OffsetDateTime.now(),
                        integerField(fields, "startMileageKm").orElse(null),
                        integerField(fields, "endMileageKm").orElseThrow(),
                        stringField(fields, "route").orElse(null),
                        integerField(fields, "durationMinutes").orElseThrow()));
        return Optional.of(new AssistantDraft(tripCreatedAnswer(event), null, event));
    }

    private Optional<AssistantDraft> createMaintenanceFromText(
            String userText,
            Vehicle vehicle,
            Map<String, Object> carriedFields) {
        Map<String, Object> fields = mergedFields(carriedFields, prefill(userText));
        fields.putIfAbsent("mileageKm", vehicle.getMileageKm());
        maintenanceName(userText).ifPresent(name -> fields.putIfAbsent("name", name));
        firstDecimal(userText, MONEY_PATTERN).ifPresent(cost -> fields.put("cost", cost));
        List<String> errors = maintenanceValidationErrors(fields, vehicle);
        if (!errors.isEmpty()) {
            return Optional.of(new AssistantDraft(missingOrInvalidAnswer("ремонт", errors), pendingAction("MAINTENANCE", fields), null));
        }
        TimelineEventResponse event = timelineEvents.createMaintenanceEvent(
                vehicle.getId(),
                new CreateMaintenanceEventRequest(
                        OffsetDateTime.now(),
                        integerField(fields, "mileageKm").orElseThrow(),
                        stringField(fields, "name").orElseThrow(),
                        userText,
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
        Matcher matcher = Pattern.compile("(?:from|из|от)\\s+(.+?)\\s+(?:to|до|в)\\s+(.+?)(?:\\s+\\d|$)", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE)
                .matcher(userText);
        if (matcher.find()) {
            return Optional.of(matcher.group(1).strip() + " -> " + matcher.group(2).strip());
        }
        return Optional.empty();
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
        String stripped = userText
                .replaceAll("(?iu)(?:на\\s+)?пробег(?:е)?\\D{0,12}-?\\d+\\s*(?:km|км).*", " ")
                .replaceAll("(?iu)(?:стоимость|цена|cost)\\D{0,12}-?\\d+(?:[.,]\\d+)?\\s*(?:rub|ruble|rubles|₽|р|руб|рублей|рубля).*", " ")
                .replaceAll("(?iu)(?:^|\\s)за\\s+-?\\d+(?:[.,]\\d+)?\\s*(?:rub|ruble|rubles|₽|р|руб|рублей|рубля).*", " ")
                .toLowerCase()
                .replaceAll("(?iu)(^|\\s)(я|i)(?=\\s|$)", " ")
                .replaceAll("(?iu)(^|\\s)(хочу|want|need|нужно|надо)(?=\\s|$)", " ")
                .replaceAll("(?iu)add repair|record repair|new repair|repair record", " ")
                .replaceAll("(?iu)добавить ремонт|записать ремонт|новый ремонт|запись ремонта", " ")
                .replaceAll("(?iu)ремонт|repair|maintenance|обслуживание|сервис", " ")
                .replaceAll("(?iu)какие данные.*|что нужно.*|что ввести.*|какие поля.*|what data.*|what fields.*", " ")
                .replaceAll("[\\p{Punct}&&[^-]]+", " ")
                .replaceAll("\\s+", " ")
                .strip();
        if (stripped.isBlank() || stripped.length() < 4 || stripped.equals("записать") || stripped.equals("добавить")) {
            return Optional.empty();
        }
        return Optional.of(stripped.substring(0, Math.min(120, stripped.length())));
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
            ChatDecision decision,
            VehicleDashboardResponse dashboard,
            AnalyticsOverviewResponse analyticsOverview,
            ChatActionResponse action) {
        return switch (decision.intent()) {
            case ASK_ANALYTICS -> analyticsAnswer(decision.language(), analyticsOverview);
            case OPEN_REFUEL_FORM, OPEN_TRIP_FORM, OPEN_PART_FORM, OPEN_REPAIR_FORM -> formAnswer(decision.language(), action);
            case ASK_REPAIR_NEED -> repairAnswer(decision.language(), dashboard);
            case ASK_FUEL -> fuelAnswer(decision.language(), analyticsOverview);
            case CASUAL -> casualAnswer(decision.language(), dashboard);
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

    private String casualAnswer(ChatLanguage language, VehicleDashboardResponse dashboard) {
        return language == ChatLanguage.RU
                ? "Привет! Я тут, на связи. Я %s %s, сейчас у меня %s км пробега, статус обслуживания: %s."
                        .formatted(dashboard.vehicle().brand(), dashboard.vehicle().model(),
                                dashboard.vehicle().mileageKm(), dashboard.maintenanceForecast().overallStatus())
                : "Hi! I am here and online. I am your %s %s, my current mileage is %s km, and my maintenance status is %s."
                        .formatted(dashboard.vehicle().brand(), dashboard.vehicle().model(),
                                dashboard.vehicle().mileageKm(), dashboard.maintenanceForecast().overallStatus());
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
}
