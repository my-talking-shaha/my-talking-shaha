package ru.talkingshaha.backend.timeline.dto;

import java.time.OffsetDateTime;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;

/**
 * Request to record a trip event. {@code startMileageKm} is optional; when present it must
 * not exceed {@code endMileageKm}. Trips carry no cost.
 */
public record CreateTripEventRequest(
        @NotNull @PastOrPresent OffsetDateTime eventDateTime,
        @PositiveOrZero Integer startMileageKm,
        @NotNull @PositiveOrZero Integer endMileageKm,
        String route,
        @NotNull @Positive Integer durationMinutes) {
}
