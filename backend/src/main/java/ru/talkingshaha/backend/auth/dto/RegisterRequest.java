package ru.talkingshaha.backend.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @Schema(example = "user@example.com")
        @NotBlank @Email @Size(max = 255)
        String email,

        @Schema(example = "secret123")
        @NotBlank
        @Size(min = 6, max = 72, message = "Password must be between 6 and 72 characters")
        @Pattern(
                regexp = "^[A-Za-z0-9()\\[\\]$#*\\-_?!.%+<>/]+$",
                message = "Password contains invalid characters")
        String password,

        @Schema(example = "Test User")
        @NotBlank @Size(max = 120)
        String displayName) {
}