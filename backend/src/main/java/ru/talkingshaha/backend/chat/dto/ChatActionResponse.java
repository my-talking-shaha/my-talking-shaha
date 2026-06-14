package ru.talkingshaha.backend.chat.dto;

import java.util.Map;

public record ChatActionResponse(String type, String form, Map<String, Object> prefill) {}