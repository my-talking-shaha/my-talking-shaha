package ru.talkingshaha.backend.timeline.controller;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class EventPhotoFlowTest {

    private static final byte[] JPEG_BYTES =
            {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46};

    private static final String EVENT_JSON =
            """
                    {
                      "eventDateTime": "2026-06-12T16:30:00Z",
                      "mileageKm": 10000,
                      "name": "Oil change",
                      "description": "Oil and filter replacement",
                      "cost": 3000
                    }
                    """;

    @Autowired
    private MockMvc mockMvc;

    private String token;

    @BeforeEach
    void registerAndAuthenticate() throws Exception {
        token = registerUser();
    }

    private String registerUser() throws Exception {
        String email = "test-" + UUID.randomUUID() + "@example.com";
        String body = mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + email
                                + "\",\"password\":\"secret123\",\"displayName\":\"Test User\"}"))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();
        return body.replaceAll(".*\"accessToken\":\"([^\"]+)\".*", "$1");
    }

    private String bearer() {
        return "Bearer " + token;
    }

    private MockMultipartFile eventPart() {
        return new MockMultipartFile("event", "event", MediaType.APPLICATION_JSON_VALUE, EVENT_JSON.getBytes());
    }

    @Test
    void storesMaintenancePhotoAndServesItThroughTheTimeline() throws Exception {
        String vehicleId = createVehicle();

        String createJson = mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/timeline/maintenance", vehicleId)
                        .file(eventPart())
                        .file(new MockMultipartFile("photos", "repair.jpg", "image/jpeg", JPEG_BYTES))
                        .header("Authorization", bearer()))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.type").value("MAINTENANCE"))
                .andExpect(jsonPath("$.name").value("Oil change"))
                .andExpect(jsonPath("$.photoUrls", hasSize(1)))
                .andExpect(jsonPath("$.photoUrls[0]").value(containsString("/api/v1/photos/")))
                .andReturn()
                .getResponse()
                .getContentAsString();

        String photoPath = createJson.replaceAll("(?s).*\"photoUrls\":\\[\"[^\"]*(/api/v1/photos/[^\"]+)\".*", "$1");

        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/timeline", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.events", hasSize(1)))
                .andExpect(jsonPath("$.events[0].photoUrls", hasSize(1)))
                .andExpect(jsonPath("$.events[0].photoUrls[0]").value(containsString("/api/v1/photos/")));

        mockMvc.perform(get(photoPath))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.IMAGE_JPEG))
                .andExpect(content().bytes(JPEG_BYTES));
    }

    @Test
    void deletingMaintenanceEventRemovesItsStoredPhoto() throws Exception {
        String vehicleId = createVehicle();

        String createJson = mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/timeline/maintenance", vehicleId)
                        .file(eventPart())
                        .file(new MockMultipartFile("photos", "repair.jpg", "image/jpeg", JPEG_BYTES))
                        .header("Authorization", bearer()))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();
        String eventId = createJson.replaceAll(".*\"id\":\"([^\"]+)\".*", "$1");
        String photoPath = createJson.replaceAll("(?s).*\"photoUrls\":\\[\"[^\"]*(/api/v1/photos/[^\"]+)\".*", "$1");

        mockMvc.perform(get(photoPath)).andExpect(status().isOk());

        mockMvc.perform(delete("/api/v1/vehicles/{vehicleId}/timeline/{eventId}", vehicleId, eventId)
                        .header("Authorization", bearer()))
                .andExpect(status().isNoContent());

        mockMvc.perform(get(photoPath)).andExpect(status().isNotFound());
    }

    @Test
    void createsMaintenanceEventWithoutPhotos() throws Exception {
        String vehicleId = createVehicle();

        mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/timeline/maintenance", vehicleId)
                        .file(eventPart())
                        .header("Authorization", bearer()))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.photoUrls", hasSize(0)));
    }

    @Test
    void rejectsNonImagePhoto() throws Exception {
        String vehicleId = createVehicle();

        mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/timeline/maintenance", vehicleId)
                        .file(eventPart())
                        .file(new MockMultipartFile("photos", "notes.txt", "text/plain", "hello".getBytes()))
                        .header("Authorization", bearer()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
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
