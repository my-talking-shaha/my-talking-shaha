package ru.talkingshaha.backend.chat.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import io.swagger.v3.oas.annotations.media.Schema;

public record TripEndRequest(
        @Schema(example = "2026-06-13T10:10:00Z")
        @PastOrPresent(message = "must not be in the future")
        OffsetDateTime endedAt,
        @Schema(example = "42")
        @PositiveOrZero(message = "must be greater than or equal to 0")
        Integer distanceKm,
        @Schema(example = "55")
        @Positive(message = "must be greater than 0")
        Integer durationMinutes,
        @Schema(example = "4.2")
        @Positive(message = "must be greater than 0")
        BigDecimal fuelLiters,
        @Schema(example = "Home -> University")
        @Size(max = 1000, message = "must be at most 1000 characters")
        String notes) {
}