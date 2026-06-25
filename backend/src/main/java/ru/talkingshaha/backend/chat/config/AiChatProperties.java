package ru.talkingshaha.backend.chat.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.ai.chat")
public record AiChatProperties(
        boolean enabled,
        String baseUrl,
        String token,
        String model,
        int maxTokens,
        double temperature) {
}