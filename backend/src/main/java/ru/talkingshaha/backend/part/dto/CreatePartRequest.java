package ru.talkingshaha.backend.part.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import ru.talkingshaha.backend.part.model.PartCategory;

public record CreatePartRequest(
        @NotBlank @Size(max = 255) String name,
        @NotNull PartCategory category,
        @NotNull LocalDate installedAt,
        @NotNull @PositiveOrZero Integer installedMileageKm,
        @Positive Integer expectedLifetimeKm,
        @Size(max = 2000) String description,
        @Positive BigDecimal cost) {}