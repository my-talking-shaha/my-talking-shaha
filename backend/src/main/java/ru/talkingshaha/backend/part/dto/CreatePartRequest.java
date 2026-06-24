package ru.talkingshaha.backend.part.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import io.swagger.v3.oas.annotations.media.Schema;
import ru.talkingshaha.backend.part.model.PartCategory;

public record CreatePartRequest(
        @Schema(example = "Brake pads")
        @NotBlank(message = "must not be blank")
        @Size(max = 255, message = "must contain at most 255 characters")
        String name,
        @Schema(example = "BRAKE_PADS")
        @NotNull(message = "must be provided")
        PartCategory category,
        @Schema(example = "2026-06-12")
        @NotNull(message = "must be provided")
        LocalDate installedAt,
        @Schema(example = "10000")
        @NotNull(message = "must be provided")
        @PositiveOrZero(message = "must be greater than or equal to 0")
        Integer installedMileageKm,
        @Schema(example = "25000")
        @Positive(message = "must be greater than 0")
        Integer expectedLifetimeKm,
        @Schema(example = "Front axle")
        @Size(max = 2000, message = "must contain at most 2000 characters")
        String description,
        @Schema(example = "2500")
        @Positive(message = "must be greater than 0")
        BigDecimal cost,
        @Schema(example = "[\"https://example.com/part-photo.jpg\"]")
        List<String> photoUrls) {}
