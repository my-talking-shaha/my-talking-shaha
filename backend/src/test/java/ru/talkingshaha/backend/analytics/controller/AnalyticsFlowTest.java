package ru.talkingshaha.backend.analytics.controller;

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
class AnalyticsFlowTest {

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

    private void seedTimelineEvents(String vehicleId) throws Exception {
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/timeline/refuel", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "eventDateTime": "2026-01-10T10:00:00Z",
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
                                          "eventDateTime": "2026-03-05T09:00:00Z",
                                          "startMileageKm": 10000,
                                          "endMileageKm": 10200,
                                          "route": "Home -> Dacha",
                                          "durationMinutes": 90
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
                                          "startMileageKm": 10200,
                                          "endMileageKm": 10400,
                                          "route": "Home -> University",
                                          "durationMinutes": 60
                                        }
                                        """))
                .andExpect(status().isCreated());
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/timeline/part", vehicleId)
                        .header("Authorization", bearer())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "eventDateTime": "2026-06-20T10:00:00Z",
                                          "mileageKm": 10450,
                                          "name": "Brake pads",
                                          "description": "Front axle replacement",
                                          "cost": 4200
                                        }
                                        """))
                .andExpect(status().isCreated());
    }

    @Test
    void filtersAnalyticsByCustomDateRange() throws Exception {
        String vehicleId = createVehicle();
        seedTimelineEvents(vehicleId);

        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics?startDate=2026-06-01&endDate=2026-06-30", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalExpenses").value(4200))
                .andExpect(jsonPath("$.expensesByCategory.FUEL").value(0))
                .andExpect(jsonPath("$.expensesByCategory.PARTS").value(4200))
                .andExpect(jsonPath("$.costPerKilometer.totalKm").value(200))
                .andExpect(jsonPath("$.hasData").value(true));
    }

    @Test
    void returnsNoDataForCustomRangeWithoutEvents() throws Exception {
        String vehicleId = createVehicle();
        seedTimelineEvents(vehicleId);

        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics?startDate=2026-02-01&endDate=2026-02-28", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalExpenses").value(0))
                .andExpect(jsonPath("$.hasData").value(false));
    }

    @Test
    void rejectsCustomRangeWithOnlyOneDate() throws Exception {
        String vehicleId = createVehicle();

        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics?startDate=2026-06-01", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    void rejectsCustomRangeWithStartAfterEnd() throws Exception {
        String vehicleId = createVehicle();

        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics?startDate=2026-06-30&endDate=2026-06-01", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    void returnsYearlyMileageTrendGroupedByMonth() throws Exception {
        String vehicleId = createVehicle();
        seedTimelineEvents(vehicleId);

        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics/mileage-trend?year=2026", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.year").value(2026))
                .andExpect(jsonPath("$.hasData").value(true))
                .andExpect(jsonPath("$.points", org.hamcrest.Matchers.hasSize(3)))
                .andExpect(jsonPath("$.points[0].label").value("Jan"))
                .andExpect(jsonPath("$.points[0].mileageKm").value(10000))
                .andExpect(jsonPath("$.points[1].label").value("Mar"))
                .andExpect(jsonPath("$.points[1].mileageKm").value(10200))
                .andExpect(jsonPath("$.points[2].label").value("Jun"))
                .andExpect(jsonPath("$.points[2].mileageKm").value(10450));
    }

    @Test
    void returnsMonthlyMileageTrendGroupedByDay() throws Exception {
        String vehicleId = createVehicle();
        seedTimelineEvents(vehicleId);

        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics/mileage-trend?year=2026&month=6", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.year").value(2026))
                .andExpect(jsonPath("$.month").value(6))
                .andExpect(jsonPath("$.hasData").value(true))
                .andExpect(jsonPath("$.points", org.hamcrest.Matchers.hasSize(2)))
                .andExpect(jsonPath("$.points[0].label").value("Jun 13"))
                .andExpect(jsonPath("$.points[0].mileageKm").value(10400))
                .andExpect(jsonPath("$.points[1].label").value("Jun 20"))
                .andExpect(jsonPath("$.points[1].mileageKm").value(10450));
    }

    @Test
    void returnsNoDataForMileageTrendWithoutEvents() throws Exception {
        String vehicleId = createVehicle();

        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics/mileage-trend?year=2099", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.points", org.hamcrest.Matchers.hasSize(0)))
                .andExpect(jsonPath("$.hasData").value(false));
    }

    @Test
    void rejectsMileageTrendWithMissingYear() throws Exception {
        String vehicleId = createVehicle();

        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics/mileage-trend", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    void rejectsMileageTrendWithInvalidMonth() throws Exception {
        String vehicleId = createVehicle();

        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics/mileage-trend?year=2026&month=13", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }
}
