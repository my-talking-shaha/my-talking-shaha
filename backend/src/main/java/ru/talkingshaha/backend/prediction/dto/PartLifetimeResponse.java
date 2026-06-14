package ru.talkingshaha.backend.prediction.dto;

import ru.talkingshaha.backend.part.model.PartStatus;

public record PartLifetimeResponse(Integer remainingKm, Integer remainingPercent, PartStatus status) {}