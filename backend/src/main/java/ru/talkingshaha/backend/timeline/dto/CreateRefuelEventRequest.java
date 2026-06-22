package ru.talkingshaha.backend.timeline.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import io.swagger.v3.oas.annotations.media.Schema;
import ru.talkingshaha.backend.vehicle.model.FuelType;

public record CreateRefuelEventRequest(
        @Schema(example = "2026-06-12T14:30:00Z")
        @NotNull(message = "must be provided")
        @PastOrPresent(message = "must not be in the future")
        OffsetDateTime eventDateTime,
        @Schema(example = "10000")
        @NotNull(message = "must be provided")
        @PositiveOrZero(message = "must be greater than or equal to 0")
        Integer mileageKm,
        @Schema(example = "30")
        @NotNull(message = "must be provided")
        @DecimalMin(value = "0", inclusive = false, message = "must be greater than 0")
        BigDecimal liters,
        @Schema(example = "2000")
        @NotNull(message = "must be provided")
        @Positive(message = "must be greater than 0")
        BigDecimal cost,
        @Schema(example = "GASOLINE")
        @NotNull(message = "must be provided")
        FuelType fuelType,
        @Schema(example = "AI-95")
        String fuelName,
        @Schema(example = "Test Station")
        String stationName) {
}
