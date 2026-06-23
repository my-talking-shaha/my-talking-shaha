package ru.talkingshaha.backend.timeline.dto;

import java.time.OffsetDateTime;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import io.swagger.v3.oas.annotations.media.Schema;

public record CreateTripEventRequest(
        @Schema(example = "2026-06-13T09:15:00Z")
        @NotNull(message = "must be provided")
        @PastOrPresent(message = "must not be in the future")
        OffsetDateTime eventDateTime,
        @Schema(example = "10000")
        @PositiveOrZero(message = "must be greater than or equal to 0")
        Integer startMileageKm,
        @Schema(example = "10400")
        @NotNull(message = "must be provided")
        @PositiveOrZero(message = "must be greater than or equal to 0")
        Integer endMileageKm,
        @Schema(example = "Home -> University")
        String route,
        @Schema(example = "60")
        @NotNull(message = "must be provided")
        @Positive(message = "must be greater than 0")
        Integer durationMinutes) {
}
