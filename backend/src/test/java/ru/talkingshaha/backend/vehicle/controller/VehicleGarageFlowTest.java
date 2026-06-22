package ru.talkingshaha.backend.vehicle.controller;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class VehicleGarageFlowTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void createsVehicleAddsPartAndReturnsDashboard() throws Exception {
        String vehicleJson = mockMvc.perform(post("/api/v1/vehicles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "brand": "Lada",
                                          "model": "2106",
                                          "productionYear": 2002,
                                          "mileageKm": 10000,
                                          "fuelType": "GASOLINE",
                                          "engineDescription": "1.6 L",
                                          "vin": "XTA21060012345678"
                                        }
                                        """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.brand").value("Lada"))
                .andReturn()
                .getResponse()
                .getContentAsString();
        String vehicleId = vehicleJson.replaceAll(".*\"id\":\"([^\"]+)\".*", "$1");
        mockMvc.perform(get("/api/v1/vehicles"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].id").value(vehicleId));
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/parts", vehicleId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "name": "Brake pads",
                                          "category": "BRAKE_PADS",
                                          "installedAt": "2026-06-12",
                                          "installedMileageKm": 9000,
                                          "expectedLifetimeKm": 25000
                                        }
                                        """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.remainingKm").value(24000))
                .andExpect(jsonPath("$.remainingPercent").value(96))
                .andExpect(jsonPath("$.status").value("OK"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/dashboard", vehicleId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vehicle.id").value(vehicleId))
                .andExpect(jsonPath("$.maintenanceForecast.overallStatus").value("OK"))
                .andExpect(jsonPath("$.maintenanceForecast.nextServiceInKm").value(24000))
                .andExpect(jsonPath("$.maintenanceForecast.parts", hasSize(1)));
    }

    @Test
    void rejectsVehicleFromFutureYear() throws Exception {
        mockMvc.perform(post("/api/v1/vehicles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "brand": "Lada",
                                          "model": "2106",
                                          "productionYear": 2099,
                                          "mileageKm": 10000,
                                          "fuelType": "GASOLINE"
                                        }
                                        """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    void createsPartEventAndReturnsAnalytics() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/timeline/refuel", vehicleId)
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
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.cost").doesNotExist())
                .andExpect(jsonPath("$.averageFuelConsumptionLitersPerKm").value(0.1));
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/timeline/part", vehicleId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "eventDateTime": "2026-06-14T10:00:00Z",
                                          "mileageKm": 10400,
                                          "name": "Brake pads",
                                          "description": "Front axle replacement",
                                          "cost": 4200,
                                          "photoUrls": ["https://example.com/brake-pads.jpg"]
                                        }
                                        """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.type").value("PART_REPLACEMENT"))
                .andExpect(jsonPath("$.name").value("Brake pads"))
                .andExpect(jsonPath("$.photoUrls[0]").value("https://example.com/brake-pads.jpg"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics?period=ALL_TIME", vehicleId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.period").value("ALL_TIME"))
                .andExpect(jsonPath("$.totalExpenses").value(6200))
                .andExpect(jsonPath("$.expensesByCategory.FUEL").value(2000))
                .andExpect(jsonPath("$.expensesByCategory.PARTS").value(4200))
                .andExpect(jsonPath("$.costPerKilometer.totalKm").value(400))
                .andExpect(jsonPath("$.costPerKilometer.costPerKm").value(15.5))
                .andExpect(jsonPath("$.fuel.averageConsumptionLitersPer100Km").value(10.0))
                .andExpect(jsonPath("$.historyAnalysis.partEventCount").value(1));
    }

    @Test
    void rejectsZeroRefuelLitersAndInvalidAnalyticsPeriod() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/timeline/refuel", vehicleId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "eventDateTime": "2026-06-12T14:30:00Z",
                                          "mileageKm": 10000,
                                          "liters": 0,
                                          "cost": 2000,
                                          "fuelType": "GASOLINE"
                                        }
                                        """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/analytics?period=WEEK", vehicleId))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
        mockMvc.perform(post("/api/v1/vehicles/{vehicleId}/timeline/part", vehicleId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(
                                """
                                        {
                                          "eventDateTime": "2026-06-14T10:00:00Z",
                                          "mileageKm": 10000,
                                          "name": "Brake pads",
                                          "cost": 0
                                        }
                                        """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fields.cost").value("must be greater than 0"));
    }

    private String createVehicle() throws Exception {
        String vehicleJson = mockMvc.perform(post("/api/v1/vehicles")
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