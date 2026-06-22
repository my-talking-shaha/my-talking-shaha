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

/**
 * Request to record a maintenance event. {@code cost}, when provided, must be positive;
 * {@code photoUrls} are optional attachments.
 */
public record CreateMaintenanceEventRequest(
        @NotNull @PastOrPresent OffsetDateTime eventDateTime,
        @NotNull @PositiveOrZero Integer mileageKm,
        @NotBlank @Size(max = 255) String name,
        String description,
        @Positive BigDecimal cost,
        List<String> photoUrls) {
}
