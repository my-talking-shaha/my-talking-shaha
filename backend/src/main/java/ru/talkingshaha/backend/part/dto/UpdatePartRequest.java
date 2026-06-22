package ru.talkingshaha.backend.part.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import ru.talkingshaha.backend.part.model.PartCategory;

/**
 * Request to partially update an installed part. All fields are optional; only the non-null
 * fields are applied, after which the part's remaining lifetime is recalculated.
 */
public record UpdatePartRequest(
        @Size(max = 255) String name,
        PartCategory category,
        LocalDate installedAt,
        @PositiveOrZero Integer installedMileageKm,
        @Positive Integer expectedLifetimeKm,
        @Size(max = 2000) String description,
        @Positive BigDecimal cost) {
}