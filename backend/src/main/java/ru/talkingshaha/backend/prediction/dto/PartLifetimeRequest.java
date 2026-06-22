package ru.talkingshaha.backend.prediction.dto;

import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import ru.talkingshaha.backend.part.model.PartCategory;

public record PartLifetimeRequest(
        @PositiveOrZero int currentMileageKm,
        @PositiveOrZero int installedMileageKm,
        @Positive Integer expectedLifetimeKm,
        PartCategory category) {}