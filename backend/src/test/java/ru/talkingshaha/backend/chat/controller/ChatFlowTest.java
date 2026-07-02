package ru.talkingshaha.backend.chat.controller;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

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

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class ChatFlowTest {

    @Autowired
    private MockMvc mockMvc;

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
    void asksForMissingRefuelFieldsInsteadOfOpeningForm() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"I refuled the car today\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("нужно указать литры")))
                .andExpect(jsonPath("$.assistantMessage.text", containsString("нужно указать стоимость")))
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/chat", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.messages[2].action").doesNotExist());
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
                .andExpect(jsonPath("$.createdEvent.liters").value(5))
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=REFUEL", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].type").value("REFUEL"))
                .andExpect(jsonPath("$.events[0].mileageKm").value(10000))
                .andExpect(jsonPath("$.events[0].liters").value(5))
                .andExpect(jsonPath("$.events[0].cost").value(1000))
                .andExpect(jsonPath("$.events[0].title").value("Заправка"))
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
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
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
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
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
    void explainsInvalidRefuelDataInsteadOfCreatingEvent() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"Я заправляла машину на 5 литров 95-м бензином за 0 рублей\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("стоимость должна быть больше 0")))
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
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
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
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
                .andExpect(jsonPath("$.createdEvent.title").value("Заправка"))
                .andExpect(jsonPath("$.createdEvent.fuelName").value("92 octane"))
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=REFUEL", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].title").value("Заправка"))
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
                .andExpect(jsonPath("$.createdEvent.distanceKm").value(12))
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=TRIP", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].type").value("TRIP"))
                .andExpect(jsonPath("$.events[0].startMileageKm").value(10000))
                .andExpect(jsonPath("$.events[0].endMileageKm").value(10012))
                .andExpect(jsonPath("$.events[0].distanceKm").value(12))
                .andExpect(jsonPath("$.events[0].durationMinutes").value(20));
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
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
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
                .andExpect(jsonPath("$.createdEvent.name").value("поменяла двигатель"))
                .andExpect(jsonPath("$.createdEvent.mileageKm").value(11000))
                .andExpect(jsonPath("$.createdEvent.cost").value(1000))
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
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
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"заменила двигатель на пробеге 10000 за 50000 рублей\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.createdEvent.type").value("MAINTENANCE"))
                .andExpect(jsonPath("$.createdEvent.name", containsString("заменила двигатель")))
                .andExpect(jsonPath("$.createdEvent.cost").value(50000))
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline?type=MAINTENANCE", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].type").value("MAINTENANCE"))
                .andExpect(jsonPath("$.events[0].name", containsString("заменила двигатель")));
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
                .andExpect(jsonPath("$.createdEvent.name", containsString("поменяла двигатель")))
                .andExpect(jsonPath("$.createdEvent.mileageKm").value(11000))
                .andExpect(jsonPath("$.createdEvent.cost").value(1000))
                .andExpect(jsonPath("$.assistantMessage.action").doesNotExist());
    }

    @Test
    void answersCasualQuestionWithVehicleContext() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"How are you?\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("Hi!")))
                .andExpect(jsonPath("$.assistantMessage.text", containsString("I am your")))
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
