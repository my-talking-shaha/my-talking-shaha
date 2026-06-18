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
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
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
}