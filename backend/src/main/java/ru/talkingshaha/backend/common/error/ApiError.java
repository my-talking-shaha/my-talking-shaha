package ru.talkingshaha.backend.common.error;

import java.util.Map;

public record ApiError(String code, String message, Map<String, String> fields) {

    public static ApiError of(String code, String message) {
        return new ApiError(code, message, Map.of());
    }
}