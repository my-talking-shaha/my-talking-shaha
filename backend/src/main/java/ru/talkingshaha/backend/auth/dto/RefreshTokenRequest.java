package ru.talkingshaha.backend.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

public record RefreshTokenRequest(
        @Schema(example = "9v_MQnHdaoeH4VmLjjKIyMQYTqHvKBvYkD7Ayq1A0mI")
        @NotBlank
        String refreshToken) {
}