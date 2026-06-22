package ru.talkingshaha.backend.timeline.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import io.swagger.v3.oas.annotations.media.Schema;

public record CreateMaintenanceEventRequest(
        @Schema(example = "2026-06-12T16:30:00Z")
        @NotNull(message = "must be provided")
        @PastOrPresent(message = "must not be in the future")
        OffsetDateTime eventDateTime,
        @Schema(example = "10000")
        @NotNull(message = "must be provided")
        @PositiveOrZero(message = "must be greater than or equal to 0")
        Integer mileageKm,
        @Schema(example = "Oil change")
        @NotBlank(message = "must not be blank")
        @Size(max = 255, message = "must contain at most 255 characters")
        String name,
        @Schema(example = "Oil and filter replacement")
        String description,
        @Schema(example = "3000")
        @Positive(message = "must be greater than 0")
        BigDecimal cost,
        @Schema(example = "[\"https://example.com/event-photo.jpg\"]")
        List<String> photoUrls) {
}
