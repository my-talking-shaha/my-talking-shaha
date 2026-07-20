package ru.talkingshaha.backend.chat.controller;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import ru.talkingshaha.backend.timeline.service.TripAutoSaveService;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class ChatFlowTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TripAutoSaveService tripAutoSave;

    private String token;

    @BeforeEach
    void registerAndAuthenticate() throws Exception {
        String email = "test-" + UUID.randomUUID() + "@example.com";
        String body = mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + email
                                + "\",\"password\":\"secret123\",\"displayName\":\"Test User\"}"))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();
        token = body.replaceAll(".*\"accessToken\":\"([^\"]+)\".*", "$1");
    }

    private String bearer() {
        return "Bearer " + token;
    }

    @Test
    void opensChatWithHistoryAndQuickQuestions() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/chat", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sessionId").exists())
                .andExpect(jsonPath("$.quickQuestions", hasSize(3)))
                .andExpect(jsonPath("$.messages", hasSize(1)))
                .andExpect(jsonPath("$.messages[0].role").value("ASSISTANT"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.messages", hasSize(1)));
    }

    @Test
    void opensChatWithRussianInitialMessageWhenLanguageRequested() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/chat?language=RU", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.quickQuestions[0]").value("Состояние авто"))
                .andExpect(jsonPath("$.messages[0].text", containsString("Привет")));
    }

    @Test
    void answersRussianAnalyticsQuestionWithRedirect() throws Exception {
        String vehicleId = createVehicleWithAnalytics();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"покажи статистику расхдов\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.userMessage.role").value("USER"))
                .andExpect(jsonPath("$.assistantMessage.role").value("ASSISTANT"))
                .andExpect(jsonPath("$.assistantMessage.text", containsString("расходы")))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("ANALYTICS"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/chat", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.messages", hasSize(3)))
                .andExpect(jsonPath("$.quickQuestions[0]").value("Состояние авто"))
                .andExpect(jsonPath("$.messages[2].action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.messages[2].action.screen").value("ANALYTICS"));
    }

    @Test
    void asksForMissingRefuelFieldsAndSuggestsPrefilledForm() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"I refuled the car today\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("liters is required")))
                .andExpect(jsonPath("$.assistantMessage.text", containsString("cost is required")))
                .andExpect(jsonPath("$.assistantMessage.text", not(containsString("нужно"))))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_FORM"))
                .andExpect(jsonPath("$.assistantMessage.action.form").value("REFUEL"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.mileageKm").value(10000));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/chat", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.messages[2].action.type").value("OPEN_FORM"))
                .andExpect(jsonPath("$.messages[2].action.form").value("REFUEL"));
    }

    @Test
    void createsRefuelEventFromCompleteChatMessage() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"I refueled AI-95 gas for 5 liters for 1000 rubles\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("REFUEL"))
                .andExpect(jsonPath("$.createdEvent.title").value("Refuel"))
                .andExpect(jsonPath("$.createdEvent.liters").value(5))
                .andExpect(jsonPath("$.assistantMessage.text", startsWith("I added the refuel")))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("HISTORY_EVENT_EDIT"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.eventId").exists())
                .andExpect(jsonPath("$.assistantMessage.action.prefill.eventType").value("REFUEL"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=REFUEL", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].type").value("REFUEL"))
                .andExpect(jsonPath("$.events[0].mileageKm").value(10000))
                .andExpect(jsonPath("$.events[0].liters").value(5))
                .andExpect(jsonPath("$.events[0].cost").value(1000))
                .andExpect(jsonPath("$.events[0].title").value("Refuel"))
                .andExpect(jsonPath("$.events[0].fuelName").value("95 octane"));
    }

    @Test
    void asksForMissingRefuelCostAndCreatesEventAfterUserClarifies() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"Я заправляла машину на 5 литров 95-м бензином\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("нужно указать стоимость")))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_FORM"))
                .andExpect(jsonPath("$.assistantMessage.action.form").value("REFUEL"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.liters").value(5))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.fuelName").value("95 octane"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=REFUEL", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(0)));
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"за 1000 рублей\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("Записала себе заправку")))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("HISTORY_EVENT_EDIT"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.eventType").value("REFUEL"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=REFUEL", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].type").value("REFUEL"))
                .andExpect(jsonPath("$.events[0].mileageKm").value(10000))
                .andExpect(jsonPath("$.events[0].liters").value(5))
                .andExpect(jsonPath("$.events[0].cost").value(1000))
                .andExpect(jsonPath("$.events[0].fuelName").value("95 octane"));
    }

    @Test
    void doesNotContinuePendingRefuelWhenUserChangesTopic() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"I refuled the car today\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.action.form").value("REFUEL"));
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"Do you hate gasoline?\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent", nullValue()))
                .andExpect(jsonPath("$.assistantMessage.action.form").doesNotExist());
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=REFUEL", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(0)));
    }

    @Test
    void explainsInvalidRefuelDataInsteadOfCreatingEvent() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"Я заправляла машину на 5 литров 95-м бензином за 0 рублей\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("стоимость должна быть больше 0")))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_FORM"))
                .andExpect(jsonPath("$.assistantMessage.action.form").value("REFUEL"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=REFUEL", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(0)));
    }

    @Test
    void rejectsUnsupportedFuelNameFromChat() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"заправилась на 5 литров, 91-й бензин, 500 рублей\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("тип топлива должен быть одним из")))
                .andExpect(jsonPath("$.assistantMessage.text", containsString("92 octane")))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_FORM"))
                .andExpect(jsonPath("$.assistantMessage.action.form").value("REFUEL"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=REFUEL", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(0)));
    }

    @Test
    void acceptsShortFuelGradeWhenCompletingPendingRefuel() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"Заправилась на 5 литров, 91-й бензин, 500 рублей\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("тип топлива должен быть одним из")));
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"92\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("REFUEL"))
                .andExpect(jsonPath("$.createdEvent.title").value("Refuel"))
                .andExpect(jsonPath("$.createdEvent.fuelName").value("92 octane"))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("HISTORY_EVENT_EDIT"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.eventType").value("REFUEL"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=REFUEL", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].title").value("Refuel"))
                .andExpect(jsonPath("$.events[0].fuelName").value("92 octane"));
    }

    @Test
    void createsTripEventFromCompleteChatMessage() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"I drove 12 km for 20 minutes\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("TRIP"))
                .andExpect(jsonPath("$.createdEvent.title").value("Trip"))
                .andExpect(jsonPath("$.createdEvent.distanceKm").value(12))
                .andExpect(jsonPath("$.assistantMessage.text", startsWith("I added the trip")))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("HISTORY_EVENT_EDIT"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.eventType").value("TRIP"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=TRIP", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].type").value("TRIP"))
                .andExpect(jsonPath("$.events[0].title").value("Trip"))
                .andExpect(jsonPath("$.events[0].startMileageKm").value(10000))
                .andExpect(jsonPath("$.events[0].endMileageKm").value(10012))
                .andExpect(jsonPath("$.events[0].distanceKm").value(12))
                .andExpect(jsonPath("$.events[0].durationMinutes").value(20));
    }

    @Test
    void createsTripEventWithRouteAndHourDurationFromChatMessage() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"у меня сегодня была поездка из Иннополиса в Казань, за 1 час проехала 60 км\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("TRIP"))
                .andExpect(jsonPath("$.createdEvent.route").value("Иннополис -> Казань"))
                .andExpect(jsonPath("$.createdEvent.distanceKm").value(60))
                .andExpect(jsonPath("$.createdEvent.durationMinutes").value(60))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("HISTORY_EVENT_EDIT"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.eventType").value("TRIP"));
    }

    @Test
    void startsAndCompletesTripLifecycleFromNaturalChatMessages() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"\\u043f\\u0440\\u0438\\u0432\\u0435\\u0442! \\u044f \\u0445\\u043e\\u0447\\u0443 \\u043d\\u0430\\u0447\\u0430\\u0442\\u044c \\u043f\\u043e\\u0435\\u0437\\u0434\\u043a\\u0443 \\u0441\\u0435\\u0439\\u0447\\u0430\\u0441\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("TRIP"))
                .andExpect(jsonPath("$.createdEvent.tripStatus").value("IN_PROGRESS"))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_FORM"))
                .andExpect(jsonPath("$.assistantMessage.action.form").value("TRIP"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.tripId").exists());
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=TRIP", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].tripStatus").value("IN_PROGRESS"));
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"We drove 12 km for 20 minutes and used 1.4 liters\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("TRIP"))
                .andExpect(jsonPath("$.createdEvent.distanceKm").value(12))
                .andExpect(jsonPath("$.createdEvent.durationMinutes").value(20))
                .andExpect(jsonPath("$.createdEvent.fuelLiters").value(1.4))
                .andExpect(jsonPath("$.createdEvent.tripStatus").value("COMPLETE"))
                .andExpect(jsonPath("$.createdEvent.endedAt").exists())
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("HISTORY_EVENT_EDIT"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.eventType").value("TRIP"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=TRIP", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].distanceKm").value(12))
                .andExpect(jsonPath("$.events[0].durationMinutes").value(20))
                .andExpect(jsonPath("$.events[0].fuelLiters").value(1.4))
                .andExpect(jsonPath("$.events[0].tripStatus").value("COMPLETE"));
    }

    @Test
    void startTripCommandOverridesPendingTripFormClarification() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"I drove today\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent").doesNotExist());
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"\\u044f \\u0445\\u043e\\u0447\\u0443 \\u043d\\u0430\\u0447\\u0430\\u0442\\u044c \\u043f\\u043e\\u0435\\u0437\\u0434\\u043a\\u0443 \\u0441\\u0435\\u0439\\u0447\\u0430\\u0441\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("TRIP"))
                .andExpect(jsonPath("$.createdEvent.tripStatus").value("IN_PROGRESS"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=TRIP", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].tripStatus").value("IN_PROGRESS"));
    }

    @Test
    void startsEndsAndCompletesTripFromChatLifecycle() throws Exception {
        String vehicleId = createVehicle();
        String startJson = mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/trips/start", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"notes\":\"Morning commute\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.tripId").exists())
                .andExpect(jsonPath("$.trip.type").value("TRIP"))
                .andExpect(jsonPath("$.trip.startMileageKm").value(10000))
                .andExpect(jsonPath("$.trip.tripStatus").value("IN_PROGRESS"))
                .andExpect(jsonPath("$.missingRequiredFields", hasSize(3)))
                .andReturn()
                .getResponse()
                .getContentAsString();
        String tripId = startJson.replaceAll(".*\"tripId\":\"([^\"]+)\".*", "$1");
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/trips/{tripId}/end", vehicleId, tripId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.confirmation", containsString("partial")))
                .andExpect(jsonPath("$.trip.tripStatus").value("PARTIAL"))
                .andExpect(jsonPath("$.missingRequiredFields", hasSize(3)));
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/trips/{tripId}/data", vehicleId, tripId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"We drove 12 km for 20 minutes and used 1.4 liters\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.extractedValues.distanceKm").value(12))
                .andExpect(jsonPath("$.extractedValues.durationMinutes").value(20))
                .andExpect(jsonPath("$.extractedValues.fuelLiters").value(1.4))
                .andExpect(jsonPath("$.trip.tripStatus").value("COMPLETE"))
                .andExpect(jsonPath("$.missingRequiredFields", hasSize(0)));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=TRIP", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].id").value(tripId))
                .andExpect(jsonPath("$.events[0].distanceKm").value(12))
                .andExpect(jsonPath("$.events[0].durationMinutes").value(20));
    }

    @Test
    void autoSavesPartialTripWhenNaturalLanguageIsUnclear() throws Exception {
        String vehicleId = createVehicle();
        String startJson = mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/trips/start", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();
        String tripId = startJson.replaceAll(".*\"tripId\":\"([^\"]+)\".*", "$1");
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/trips/{tripId}/data", vehicleId, tripId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"not sure, maybe later\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.confirmation", containsString("partial")))
                .andExpect(jsonPath("$.trip.tripStatus").value("PARTIAL"))
                .andExpect(jsonPath("$.extractedValues").isEmpty())
                .andExpect(jsonPath("$.missingRequiredFields", hasSize(3)));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=TRIP", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].id").value(tripId));
    }

    @Test
    void autoSavesAbandonedInProgressTripAsPartial() throws Exception {
        String vehicleId = createVehicle();
        String startJson = mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/trips/start", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.trip.tripStatus").value("IN_PROGRESS"))
                .andReturn()
                .getResponse()
                .getContentAsString();
        String tripId = startJson.replaceAll(".*\"tripId\":\"([^\"]+)\".*", "$1");
        tripAutoSave.autoSaveAbandonedTrips(OffsetDateTime.now().plusSeconds(1), OffsetDateTime.now());
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=TRIP", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].id").value(tripId))
                .andExpect(jsonPath("$.events[0].tripStatus").value("PARTIAL"))
                .andExpect(jsonPath("$.events[0].endedAt").exists());
    }

    @Test
    void explainsRepairFieldsQuestionWithoutCreatingEvent() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"Я ездила на ремонт, меняла двигатель. Какие данные нужно ввести?\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("Для ремонта")))
                .andExpect(jsonPath("$.assistantMessage.text", containsString("Без описания работы")))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_FORM"))
                .andExpect(jsonPath("$.assistantMessage.action.form").value("MAINTENANCE"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.mileageKm").value(10000));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=MAINTENANCE", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(0)));
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"Поменяла двигатель, пробег 11000 км, стоимость 1000 рублей\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("MAINTENANCE"))
                .andExpect(jsonPath("$.createdEvent.name").value("замена двигателя"))
                .andExpect(jsonPath("$.createdEvent.description").value("поменяла двигатель\nReplaced parts: двигатель"))
                .andExpect(jsonPath("$.createdEvent.mileageKm").value(11000))
                .andExpect(jsonPath("$.createdEvent.cost").value(1000))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("HISTORY_EVENT_EDIT"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.eventType").value("MAINTENANCE"));
    }

    @Test
    void asksForRepairDescriptionAndCreatesMaintenanceAfterClarification() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"Я хочу записать ремонт\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("нужно описание работы")))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_FORM"))
                .andExpect(jsonPath("$.assistantMessage.action.form").value("MAINTENANCE"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.mileageKm").value(10000));
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"заменила двигатель на пробеге 10000 за 50000 рублей\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("MAINTENANCE"))
                .andExpect(jsonPath("$.createdEvent.name").value("замена двигателя"))
                .andExpect(jsonPath("$.createdEvent.description").value("заменила двигатель\nReplaced parts: двигатель"))
                .andExpect(jsonPath("$.createdEvent.cost").value(50000))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("HISTORY_EVENT_EDIT"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.eventType").value("MAINTENANCE"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=MAINTENANCE", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].type").value("MAINTENANCE"))
                .andExpect(jsonPath("$.events[0].name").value("замена двигателя"));
    }

    @Test
    void createsMaintenanceWhenRepairMessageContainsCostWord() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"я ещё поменяла двигатель, пробег сейчас 11000 км, стоило 1000 рублей\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("MAINTENANCE"))
                .andExpect(jsonPath("$.createdEvent.name").value("замена двигателя"))
                .andExpect(jsonPath("$.createdEvent.description").value("поменяла двигатель\nReplaced parts: двигатель"))
                .andExpect(jsonPath("$.createdEvent.mileageKm").value(11000))
                .andExpect(jsonPath("$.createdEvent.cost").value(1000))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("HISTORY_EVENT_EDIT"))
                .andExpect(jsonPath("$.assistantMessage.action.prefill.eventType").value("MAINTENANCE"));
    }

    @Test
    void answersCasualQuestionWithVehicleContext() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"text\":\"How are you?\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", not(containsString("Hi!"))))
                .andExpect(jsonPath("$.assistantMessage.text", containsString("I am here")))
                .andExpect(jsonPath("$.assistantMessage.text", containsString("10000 km")))
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
    }

    @Test
    void reportsRepairNeedAndRedirectsToMaintenanceForecast() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/parts", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "name": "Timing belt",
                                          "category": "TIMING_BELT",
                                          "installedAt": "2026-06-12",
                                          "installedMileageKm": 9500,
                                          "expectedLifetimeKm": 500
                                        }
                                        """))
                .andExpect(status().isCreated());
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"Что может сломаться скоро?\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("Timing belt")))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("MAINTENANCE_FORECAST"));
    }

    @Test
    void repairNeedWinsOverCasualGreetingInMixedMessage() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/parts", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "name": "Timing belt",
                                          "category": "TIMING_BELT",
                                          "installedAt": "2026-06-12",
                                          "installedMileageKm": 9500,
                                          "expectedLifetimeKm": 500
                                        }
                                        """))
                .andExpect(status().isCreated());
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"как ты? что может сломаться в ближайшее время?\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("Timing belt")))
                .andExpect(jsonPath("$.assistantMessage.text", not(containsString("Привет"))))
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_SCREEN"))
                .andExpect(jsonPath("$.assistantMessage.action.screen").value("MAINTENANCE_FORECAST"));
    }

    @Test
    void returnsFallbackWithSuggestionsForUnclearQuestion() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"синяя луна вчера\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("Можешь спросить")))
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
    }

    private String createVehicleWithAnalytics() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/timeline/refuel", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "eventDateTime": "2026-06-12T14:30:00Z",
                                          "title": "Refuel at Lukoil",
                                          "mileageKm": 10000,
                                          "liters": 40,
                                          "cost": 2000,
                                          "fuelType": "GASOLINE",
                                          "fuelName": "AI-95"
                                        }
                                        """))
                .andExpect(status().isCreated());
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/timeline/trip", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "eventDateTime": "2026-06-13T09:15:00Z",
                                          "title": "Trip to university",
                                          "startMileageKm": 10000,
                                          "endMileageKm": 10400,
                                          "route": "Home -> University",
                                          "durationMinutes": 60
                                        }
                                        """))
                .andExpect(status().isCreated());
        return vehicleId;
    }

    private String createVehicle() throws Exception {
        String vehicleJson = mockMvc.perform(post("/api/v1/vehicles")
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "brand": "Lada",
                                          "model": "2106",
                                          "productionYear": 2002,
                                          "mileageKm": 10000,
                                          "fuelType": "GASOLINE"
                                        }
                                        """))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();
        return vehicleJson.replaceAll(".*\"id\":\"([^\"]+)\".*", "$1");
    }
}
