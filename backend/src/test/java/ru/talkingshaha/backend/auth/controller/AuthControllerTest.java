package ru.talkingshaha.backend.auth.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.empty;
import static org.hamcrest.Matchers.emptyString;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import ru.talkingshaha.backend.auth.repository.RefreshTokenRepository;
import ru.talkingshaha.backend.user.repository.AppUserRepository;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AppUserRepository appUserRepository;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Test
    void registerCreatesUserSignsInAndStartsWithEmptyGarage() throws Exception {
        String email = uniqueEmail();
        JsonNode response = register(email, "secret123", "Test User");
        assertThat(response.get("user").get("email").asText()).isEqualTo(email);
        assertThat(response.get("accessToken").asText()).isNotBlank();
        assertThat(response.get("refreshToken").asText()).isNotBlank();
        mockMvc.perform(get("/api/v1/vehicles")
                        .header("Authorization", "Bearer " + response.get("accessToken").asText()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", empty()));
    }

    @Test
    void rejectsDuplicateEmail() throws Exception {
        String email = uniqueEmail();
        register(email, "secret123", "Test User");
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(registerJson(email, "secret123", "Test User")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("EMAIL_ALREADY_EXISTS"));
    }

    @Test
    void validatesPasswordRules() throws Exception {
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(registerJson(uniqueEmail(), "short", "Test User")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.fields.password").exists());
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(registerJson(uniqueEmail(), "secret@", "Test User")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.fields.password").value("Password contains invalid characters"));
    }

    @Test
    void logsInWithCorrectPasswordAndRejectsWrongPassword() throws Exception {
        String email = uniqueEmail();
        register(email, "secret123", "Test User");
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginJson(email, "wrong123")))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginJson(email, "secret123")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.user.email").value(email))
                .andExpect(jsonPath("$.accessToken").value(not(emptyString())))
                .andExpect(jsonPath("$.refreshToken").value(not(emptyString())));
    }

    @Test
    void refreshRotatesRefreshTokenAndLogoutInvalidatesIt() throws Exception {
        JsonNode registration = register(uniqueEmail(), "secret123", "Test User");
        String refreshToken = registration.get("refreshToken").asText();
        JsonNode refreshed = objectMapper.readTree(mockMvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(refreshJson(refreshToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken").value(not(emptyString())))
                .andExpect(jsonPath("$.refreshToken").value(not(emptyString())))
                .andReturn()
                .getResponse()
                .getContentAsString());
        mockMvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(refreshJson(refreshToken)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
        String rotatedRefreshToken = refreshed.get("refreshToken").asText();
        mockMvc.perform(post("/api/v1/auth/logout")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(refreshJson(rotatedRefreshToken)))
                .andExpect(status().isNoContent());
        mockMvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(refreshJson(rotatedRefreshToken)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
    }

    @Test
    void storesPasswordAsHash() throws Exception {
        String email = uniqueEmail();
        register(email, "secret123", "Test User");
        String storedPassword = appUserRepository.findByEmail(email).orElseThrow().getPasswordHash();
        assertThat(storedPassword)
                .isNotEqualTo("secret123")
                .startsWith("$2");
        assertThat(refreshTokenRepository.count()).isEqualTo(1);
    }

    private JsonNode register(String email, String password, String displayName) throws Exception {
        return objectMapper.readTree(mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(registerJson(email, password, displayName)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.user.email").value(email))
                .andExpect(jsonPath("$.user.displayName").value(displayName))
                .andReturn()
                .getResponse()
                .getContentAsString());
    }

    private String registerJson(String email, String password, String displayName) {
        return """
                {
                  "email": "%s",
                  "password": "%s",
                  "displayName": "%s"
                }
                """
                .formatted(email, password, displayName);
    }

    private String loginJson(String email, String password) {
        return """
                {
                  "email": "%s",
                  "password": "%s"
                }
                """
                .formatted(email, password);
    }

    private String refreshJson(String refreshToken) {
        return """
                {
                  "refreshToken": "%s"
                }
                """
                .formatted(refreshToken);
    }

    private String uniqueEmail() {
        return "test-" + UUID.randomUUID() + "@example.com";
    }
}
