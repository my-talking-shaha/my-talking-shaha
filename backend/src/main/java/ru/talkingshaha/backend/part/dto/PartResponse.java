package ru.talkingshaha.backend.part.dto;

import java.time.LocalDate;
import java.util.UUID;

import ru.talkingshaha.backend.part.model.PartCategory;
import ru.talkingshaha.backend.part.model.PartStatus;

public record PartResponse(
        UUID id,
        String name,
        PartCategory category,
        LocalDate installedAt,
        Integer installedMileageKm,
        Integer expectedLifetimeKm,
        Integer remainingKm,
        Integer remainingPercent,
        PartStatus status) {
}