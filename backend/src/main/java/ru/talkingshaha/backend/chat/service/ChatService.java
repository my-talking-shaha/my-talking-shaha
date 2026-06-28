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
import ru.talkingshaha.backend.vehicle.dto.VehicleDashboardResponse;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.service.VehicleService;

@Service
public class ChatService {

    private static final Pattern NUMBER_PATTERN = Pattern.compile("\\d+");

    private final VehicleService vehicles;
    private final AnalyticsService analytics;
    private final ChatSessionRepository sessions;
    private final ChatMessageRepository messages;
    private final ChatIntentResolver intentResolver;
    private final AiChatClient aiChatClient;
    private final ObjectMapper objectMapper;

    public ChatService(
            VehicleService vehicles,
            AnalyticsService analytics,
            ChatSessionRepository sessions,
            ChatMessageRepository messages,
            ChatIntentResolver intentResolver,
            AiChatClient aiChatClient,
            ObjectMapper objectMapper) {
        this.vehicles = vehicles;
        this.analytics = analytics;
        this.sessions = sessions;
        this.messages = messages;
        this.intentResolver = intentResolver;
        this.aiChatClient = aiChatClient;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public ChatStateResponse state(UUID vehicleId) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        ChatSession session = getOrCreateSession(vehicle);
        List<ChatMessageResponse> history = messages.findAllBySessionOrderByCreatedAtAsc(session).stream()
                .map(this::toResponse)
                .toList();
        return new ChatStateResponse(session.getId(), quickQuestions(history), history);
    }

    @Transactional
    public ChatMessagesResponse messages(UUID vehicleId) {
        return new ChatMessagesResponse(state(vehicleId).messages());
    }

    @Transactional
    public SendMessageResponse send(UUID vehicleId, SendMessageRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        ChatSession session = getOrCreateSession(vehicle);
        ChatMessage userMessage = saveMessage(session, ChatMessageRole.USER, request.text());

        VehicleDashboardResponse dashboard = vehicles.dashboard(vehicleId);
        AnalyticsOverviewResponse analyticsOverview = analytics.overview(vehicleId, AnalyticsPeriod.ALL_TIME);
        String baseContext = context(dashboard, analyticsOverview);
        ChatDecision decision = intentResolver.resolve(request.text(), baseContext);
        AssistantDraft assistantDraft = assistantDraft(request.text(), decision, dashboard, analyticsOverview);
        ChatMessage assistantMessage = saveMessage(
                session,
                ChatMessageRole.ASSISTANT,
                assistantDraft.text(),
                assistantDraft.action());

        return new SendMessageResponse(
                toResponse(userMessage),
                toResponse(assistantMessage));
    }

    private AssistantDraft assistantDraft(
            String userText,
            ChatDecision decision,
            VehicleDashboardResponse dashboard,
            AnalyticsOverviewResponse analyticsOverview) {
        ChatActionResponse action = action(decision, userText);
        String context = contextForDecision(decision, dashboard, analyticsOverview, action);
        String text = aiChatClient.answer(userText, decision, context)
                .orElseGet(() -> templateAnswer(decision, dashboard, analyticsOverview, action));
        return new AssistantDraft(text, action);
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
            case ASK_STATUS -> new ChatActionResponse("OPEN_SCREEN", null, "DASHBOARD", Map.of());
            case UNCLEAR -> null;
        };
    }

    private Map<String, Object> prefill(String userText) {
        Map<String, Object> prefill = new LinkedHashMap<>();
        firstNumber(userText).ifPresent(value -> prefill.put("mileageKm", value));
        return prefill;
    }

    private Optional<Integer> firstNumber(String userText) {
        Matcher matcher = NUMBER_PATTERN.matcher(userText);
        return matcher.find() ? Optional.of(Integer.parseInt(matcher.group())) : Optional.empty();
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
            case ASK_STATUS -> statusAnswer(decision.language(), dashboard);
            case UNCLEAR -> unclearAnswer(decision.language());
        };
    }

    private String analyticsAnswer(ChatLanguage language, AnalyticsOverviewResponse overview) {
        if (!overview.hasData()) {
            return language == ChatLanguage.RU
                    ? "Недостаточно данных для ответа. Добавьте поездки, заправки или записи обслуживания, и я смогу посчитать аналитику. Возможно, вы хотели проверить расходы, состояние авто или добавить событие?"
                    : "There is not enough data to answer. Add trips, refuels, or maintenance records so I can calculate analytics. You may have meant expenses, vehicle status, or adding an event.";
        }
        String text = "Expenses: %s %s, cost per km: %s, fuel consumption: %s L/100 km. You can check the analytics dashboard for more details."
                .formatted(money(overview.totalExpenses()), overview.currency(),
                        overview.costPerKilometer().costPerKm(),
                        overview.fuel().averageConsumptionLitersPer100Km());
        return language == ChatLanguage.RU
                ? "Расходы: %s %s, стоимость 1 км: %s, расход топлива: %s л/100 км. Вы можете открыть экран аналитики, чтобы увидеть больше деталей."
                        .formatted(money(overview.totalExpenses()), overview.currency(),
                                overview.costPerKilometer().costPerKm(),
                                overview.fuel().averageConsumptionLitersPer100Km())
                : text;
    }

    private String formAnswer(ChatLanguage language, ChatActionResponse action) {
        String form = action == null ? "the form" : action.form();
        return language == ChatLanguage.RU
                ? "Похоже, это нужно записать в историю автомобиля. Я могу открыть форму %s и передать туда найденные данные."
                        .formatted(form)
                : "This looks like something to record in the vehicle history. I can open the %s form and pass the extracted data."
                        .formatted(form);
    }

    private String repairAnswer(ChatLanguage language, VehicleDashboardResponse dashboard) {
        List<PartResponse> parts = dashboard.maintenanceForecast().parts();
        if (parts.isEmpty()) {
            return language == ChatLanguage.RU
                    ? "Недостаточно данных для ответа. Добавьте детали автомобиля или записи обслуживания, и я смогу оценить срочность ремонта."
                    : "There is not enough data to answer. Add vehicle parts or maintenance records so I can estimate repair urgency.";
        }
        PartResponse urgent = parts.stream()
                .min(Comparator.comparing(part -> part.remainingKm() == null ? Integer.MAX_VALUE : part.remainingKm()))
                .orElseThrow();
        boolean warning = urgent.status() == PartStatus.CRITICAL || urgent.status() == PartStatus.ATTENTION;
        if (language == ChatLanguage.RU) {
            return "Общий статус: %s. Самая срочная деталь: %s, осталось %s км (%s%%), статус %s. %s Откройте прогноз обслуживания, чтобы посмотреть весь список."
                    .formatted(dashboard.maintenanceForecast().overallStatus(), urgent.name(), urgent.remainingKm(),
                            urgent.remainingPercent(), urgent.status(),
                            warning ? "Лучше запланировать обслуживание." : "Срочного ремонта не предвидется.");
        }
        return "Overall status: %s. Most urgent part: %s, %s km left (%s%%), status %s. %s Open the maintenance forecast to see the full report."
                .formatted(dashboard.maintenanceForecast().overallStatus(), urgent.name(), urgent.remainingKm(),
                        urgent.remainingPercent(), urgent.status(),
                        warning ? "Plan maintenance soon." : "No urgent repair is visible.");
    }

    private String statusAnswer(ChatLanguage language, VehicleDashboardResponse dashboard) {
        return language == ChatLanguage.RU
                ? "Сейчас пробег %s км, общий статус обслуживания: %s, ближайший сервис через %s км."
                        .formatted(dashboard.vehicle().mileageKm(),
                                dashboard.maintenanceForecast().overallStatus(),
                                dashboard.maintenanceForecast().nextServiceInKm())
                : "Current mileage is %s km, maintenance status is %s, next service is in %s km."
                        .formatted(dashboard.vehicle().mileageKm(),
                                dashboard.maintenanceForecast().overallStatus(),
                                dashboard.maintenanceForecast().nextServiceInKm());
    }

    private String unclearAnswer(ChatLanguage language) {
        return language == ChatLanguage.RU
                ? "Я не до конца понял вопрос. Возможно, вы хотели посмотреть аналитику, проверить состояние авто или добавить заправку/поездку/ремонт?"
                : "I did not fully understand the question. Did you mean analytics, vehicle condition, or adding a refuel/trip/repair record?";
    }

    private String money(BigDecimal value) {
        return value == null ? "0" : value.stripTrailingZeros().toPlainString();
    }

    private ChatSession getOrCreateSession(Vehicle vehicle) {
        return sessions.findByVehicle(vehicle).orElseGet(() -> {
            ChatSession session = new ChatSession();
            session.setVehicle(vehicle);
            session.setCreatedAt(OffsetDateTime.now());
            ChatSession saved = sessions.save(session);
            saveMessage(saved, ChatMessageRole.ASSISTANT, "The assistant is ready.");
            return saved;
        });
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

    private List<String> quickQuestions(List<ChatMessageResponse> history) {
        ChatLanguage language = history.stream()
                .filter(message -> message.role() == ChatMessageRole.USER)
                .reduce((first, second) -> second)
                .map(message -> message.text().chars()
                        .anyMatch(ch -> Character.UnicodeBlock.of(ch) == Character.UnicodeBlock.CYRILLIC)
                        ? ChatLanguage.RU
                        : ChatLanguage.EN)
                .orElse(ChatLanguage.EN);
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

    private record AssistantDraft(String text, ChatActionResponse action) {
    }
}
