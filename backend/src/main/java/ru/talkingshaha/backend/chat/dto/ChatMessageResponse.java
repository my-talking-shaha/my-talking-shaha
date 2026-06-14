package ru.talkingshaha.backend.chat.dto;

import java.time.OffsetDateTime;
import java.util.UUID;
import ru.talkingshaha.backend.chat.model.ChatMessageRole;

public record ChatMessageResponse(
        UUID id, ChatMessageRole role, String text, OffsetDateTime createdAt, ChatActionResponse action) {}