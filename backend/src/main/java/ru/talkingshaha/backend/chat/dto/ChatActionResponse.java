package ru.talkingshaha.backend.chat.dto;

import java.util.Map;

public record ChatActionResponse(String type, String form, String screen, Map<String, Object> prefill) {}