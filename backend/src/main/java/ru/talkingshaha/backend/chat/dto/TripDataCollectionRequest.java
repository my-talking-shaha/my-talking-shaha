package ru.talkingshaha.backend.chat.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import io.swagger.v3.oas.annotations.media.Schema;

public record TripDataCollectionRequest(
        @Schema(example = "We drove 42 km for 55 minutes and used about 4 liters")
        @NotBlank(message = "must be provided")
        @Size(max = 1000, message = "must be at most 1000 characters")
        String text) {
}