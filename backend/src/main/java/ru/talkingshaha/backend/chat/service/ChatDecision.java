package ru.talkingshaha.backend.chat.service;

import java.util.Map;

public record ChatDecision(
        ChatIntent intent,
        ChatLanguage language,
        double confidence,
        Map<String, Object> extractedFields) {

    public static ChatDecision unclear(ChatLanguage language) {
        return new ChatDecision(ChatIntent.UNCLEAR, language, 0, Map.of());
    }
}