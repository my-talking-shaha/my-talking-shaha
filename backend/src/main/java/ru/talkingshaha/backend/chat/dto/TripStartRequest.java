package ru.talkingshaha.backend.chat.dto;

import java.time.OffsetDateTime;

import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Size;
import io.swagger.v3.oas.annotations.media.Schema;

public record TripStartRequest(
        @Schema(example = "2026-06-13T09:15:00Z")
        @PastOrPresent(message = "must not be in the future")
        OffsetDateTime startedAt,
        @Schema(example = "Morning commute")
        @Size(max = 1000, message = "must be at most 1000 characters")
        String notes) {
}