package ru.talkingshaha.backend.vehicle.controller;

import java.util.UUID;
import java.util.concurrent.TimeUnit;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import org.springframework.core.io.Resource;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.talkingshaha.backend.common.error.ApiError;
import ru.talkingshaha.backend.vehicle.service.VehiclePhotoService;

@RestController
@RequestMapping("/api/v1/photos")
public class PhotoContentController {

    private final VehiclePhotoService photos;

    public PhotoContentController(VehiclePhotoService photos) {
        this.photos = photos;
    }

    @Operation(summary = "Get photo content", security = {})
    @ApiResponse(
            responseCode = "404",
            description = "Photo not found",
            content = @Content(schema = @Schema(implementation = ApiError.class)))
    @GetMapping("/{photoId}")
    public ResponseEntity<Resource> photoContent(@PathVariable UUID photoId) {
        VehiclePhotoService.PhotoContent content = photos.photoContent(photoId);
        return ResponseEntity.ok()
                .contentType(content.contentType())
                .cacheControl(CacheControl.maxAge(365, TimeUnit.DAYS).cachePublic().immutable())
                .body(content.resource());
    }
}
