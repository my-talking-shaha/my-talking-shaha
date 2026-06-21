package ru.talkingshaha.backend.part.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import ru.talkingshaha.backend.part.model.PartCategory;

/**
 * Request to register a newly installed part. {@code expectedLifetimeKm} is optional; when
 * omitted, a per-category default is used to estimate the lifetime. {@code description} and
 * {@code cost} are optional metadata about the installation.
 */
public record CreatePartRequest(
        @NotBlank @Size(max = 255) String name,
        @NotNull PartCategory category,
        @NotNull LocalDate installedAt,
        @NotNull @PositiveOrZero Integer installedMileageKm,
        @Positive Integer expectedLifetimeKm,
        @Size(max = 2000) String description,
        @Positive BigDecimal cost) {}