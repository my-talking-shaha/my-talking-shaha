package ru.talkingshaha.backend.timeline.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;

public record CreateTripEventRequest(
        @NotNull @PastOrPresent OffsetDateTime eventDateTime,
        @PositiveOrZero Integer startMileageKm,
        @NotNull @PositiveOrZero Integer endMileageKm,
        String route,
        @NotNull @Positive Integer durationMinutes,
        @Positive BigDecimal cost) {
}
