package ru.talkingshaha.backend.chat.dto;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import ru.talkingshaha.backend.timeline.dto.TimelineEventResponse;

public record TripLifecycleResponse(
        UUID tripId,
        String confirmation,
        List<String> missingRequiredFields,
        Map<String, Object> extractedValues,
        TimelineEventResponse trip) {
}