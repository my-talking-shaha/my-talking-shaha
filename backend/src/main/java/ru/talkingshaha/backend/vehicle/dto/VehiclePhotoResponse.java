package ru.talkingshaha.backend.vehicle.dto;

import java.util.UUID;

import io.swagger.v3.oas.annotations.media.Schema;

public record VehiclePhotoResponse(
        @Schema(example = "3f2a6c1e-8b4d-4c2a-9f1e-5d7b8a9c0d1f")
        UUID photoId,
        @Schema(example = "https://example.com/api/v1/photos/3f2a6c1e-8b4d-4c2a-9f1e-5d7b8a9c0d1f")
        String url) {}
