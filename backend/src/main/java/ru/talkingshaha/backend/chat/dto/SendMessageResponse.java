package ru.talkingshaha.backend.chat.dto;

public record SendMessageResponse(
        ChatMessageResponse userMessage,
        ChatMessageResponse assistantMessage) {
}