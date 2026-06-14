package ru.talkingshaha.backend.prediction.dto;

import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;

public record PartLifetimeRequest(
        @PositiveOrZero int currentMileageKm,
        @PositiveOrZero int installedMileageKm,
        @Positive Integer expectedLifetimeKm) {}