package ru.talkingshaha.backend.chat.dto;

import ru.talkingshaha.backend.timeline.dto.TimelineEventResponse;

public record SendMessageResponse(
        ChatMessageResponse userMessage,
        ChatMessageResponse assistantMessage,
        TimelineEventResponse createdEvent) {
}