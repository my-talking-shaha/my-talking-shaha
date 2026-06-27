package ru.talkingshaha.backend.chat.service;

import java.util.Optional;

public interface AiChatClient {
    Optional<ChatDecision> classify(String userText, String context);

    Optional<String> answer(String userText, ChatDecision decision, String context);
}