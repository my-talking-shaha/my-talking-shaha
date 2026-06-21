package ru.talkingshaha.backend.timeline.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import ru.talkingshaha.backend.vehicle.model.FuelTy pe;

public record CreateRefuelEventRequest(
        @NotNull @PastOrPresent OffsetDateTime eventDateTime,
        @NotNull @PositiveOrZero Integer mileageKm,
        @NotNull @DecimalMin("0") @DecimalMax("1000") BigDecimal liters,
        @NotNull @Positive BigDecimal cost,
        @NotNull FuelType fuelType,
        String fuelName,
        String stationName) {
}
