package ru.talkingshaha.backend.timeline.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import io.swagger.v3.oas.annotations.media.Schema;

public record CreatePartEventRequest(
        @Schema(example = "2026-06-14T10:00:00Z")
        @NotNull(message = "must be provided")
        @PastOrPresent(message = "must not be in the future")
        OffsetDateTime eventDateTime,
        @Schema(example = "10400")
        @NotNull(message = "must be provided")
        @PositiveOrZero(message = "must be greater than or equal to 0")
        Integer mileageKm,
        @Schema(example = "Brake pads")
        @NotBlank(message = "must not be blank")
        @Size(max = 255, message = "must contain at most 255 characters")
        String name,
        @Schema(example = "Front axle replacement")
        String description,
        @Schema(example = "4200")
        @Positive(message = "must be greater than 0")
        BigDecimal cost,
        @Schema(example = "[\"https://example.com/brake-pads.jpg\"]")
        List<String> photoUrls) {
}