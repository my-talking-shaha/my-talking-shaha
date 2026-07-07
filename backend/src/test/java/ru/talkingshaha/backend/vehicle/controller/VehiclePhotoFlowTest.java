package ru.talkingshaha.backend.vehicle.controller;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.notNullValue;
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
class VehiclePhotoFlowTest {

    private static final byte[] JPEG_BYTES =
            {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46};
    private static final byte[] PNG_BYTES =
            {(byte) 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D};

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

    @Test
    void uploadsListsServesAndDeletesPhotos() throws Exception {
        String vehicleId = createVehicle();
        String uploadJson = mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/photos", vehicleId)
                        .file(new MockMultipartFile("file", "car.jpg", "image/jpeg", JPEG_BYTES))
                        .header("Authorization", bearer()))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.photoId").value(notNullValue()))
                .andExpect(jsonPath("$.url").value(containsString("/api/v1/photos/")))
                .andReturn()
                .getResponse()
                .getContentAsString();
        String photoId = uploadJson.replaceAll(".*\"photoId\":\"([^\"]+)\".*", "$1");
        mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/photos", vehicleId)
                        .file(new MockMultipartFile("file", "car.png", "image/png", PNG_BYTES))
                        .header("Authorization", bearer()))
                .andExpect(status().isCreated());
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/photos", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.photos", hasSize(2)))
                .andExpect(jsonPath("$.photos[0].photoId").value(photoId));
        mockMvc.perform(get("/api/v1/vehicles").header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].photoUrl").value(containsString(photoId)));
        mockMvc.perform(get("/api/v1/photos/{photoId}", photoId))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.IMAGE_JPEG))
                .andExpect(content().bytes(JPEG_BYTES));
        mockMvc.perform(delete("/api/v1/vehicles/{vehicleId}/photos/{photoId}", vehicleId, photoId)
                        .header("Authorization", bearer()))
                .andExpect(status().isNoContent());
        mockMvc.perform(get("/api/v1/vehicles/{vehicleId}/photos", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.photos", hasSize(1)));
        mockMvc.perform(get("/api/v1/photos/{photoId}", photoId))
                .andExpect(status().isNotFound());
    }

    @Test
    void rejectsUnsupportedAndMismatchedFiles() throws Exception {
        String vehicleId = createVehicle();
        mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/photos", vehicleId)
                        .file(new MockMultipartFile("file", "notes.txt", "text/plain", "hello".getBytes()))
                        .header("Authorization", bearer()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
        mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/photos", vehicleId)
                        .file(new MockMultipartFile("file", "car.jpg", "image/jpeg", PNG_BYTES))
                        .header("Authorization", bearer()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
        mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/photos", vehicleId)
                        .file(new MockMultipartFile("file", "empty.jpg", "image/jpeg", new byte[0]))
                        .header("Authorization", bearer()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
        mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/photos", vehicleId)
                        .header("Authorization", bearer()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.fields.file").value("must be provided"));
    }

    @Test
    void rejectsPhotoUploadToForeignVehicle() throws Exception {
        String vehicleId = createVehicle();
        token = registerUser();
        mockMvc.perform(multipart("/api/v1/vehicles/{vehicleId}/photos", vehicleId)
                        .file(new MockMultipartFile("file", "car.jpg", "image/jpeg", JPEG_BYTES))
                        .header("Authorization", bearer()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));
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
