package ru.talkingshaha.backend.chat.dto;

import java.util.List;
import java.util.UUID;

public record ChatStateResponse(
        UUID sessionId,
        List<String> quickQuestions,
        List<ChatMessageResponse> messages) {
}