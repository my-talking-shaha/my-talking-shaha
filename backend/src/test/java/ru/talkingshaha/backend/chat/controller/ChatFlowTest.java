package ru.talkingshaha.backend.chat.controller;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
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
    void answersRussianAnalyticsQuestionWithRedirect() throws Exception {
        String vehicleId = createVehicleWithAnalytics();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"покажи статистику расхдов\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.userMessage.role").value("USER"))
                .andExpect(jsonPath("$.assistantMessage.role").value("ASSISTANT"))
                .andExpect(jsonPath("$.assistantMessage.text", containsString("Расходы")))
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
    void redirectsEnglishRefuelQuestionWithTypoToForm() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"I refuled the car today\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.action.type").value("OPEN_FORM"))
                .andExpect(jsonPath("$.assistantMessage.action.form").value("REFUEL"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/chat", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.messages[2].action.type").value("OPEN_FORM"))
                .andExpect(jsonPath("$.messages[2].action.form").value("REFUEL"));
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
    void returnsFallbackWithSuggestionsForUnclearQuestion() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/chat/messages", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"синяя луна вчера\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.assistantMessage.text", containsString("Возможно")))
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
