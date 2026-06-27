package ru.talkingshaha.backend.auth.dto;

public record AuthResponse(UserResponse user, String accessToken, String refreshToken) {
}