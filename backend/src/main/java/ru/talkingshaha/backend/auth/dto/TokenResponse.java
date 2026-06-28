package ru.talkingshaha.backend.auth.dto;

public record TokenResponse(String accessToken, String refreshToken) {
}