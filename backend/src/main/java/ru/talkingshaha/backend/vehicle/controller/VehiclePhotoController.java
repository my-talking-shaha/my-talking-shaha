package ru.talkingshaha.backend.vehicle.controller;

import java.util.UUID;

import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import ru.talkingshaha.backend.common.error.ApiError;
import ru.talkingshaha.backend.vehicle.dto.VehiclePhotoListResponse;
import ru.talkingshaha.backend.vehicle.dto.VehiclePhotoResponse;
import ru.talkingshaha.backend.vehicle.service.VehiclePhotoService;

@RestController
@RequestMapping("/api/v1/vehicles/{vehicleId}/photos")
@ApiResponses({
        @ApiResponse(
                responseCode = "400",
                description = "Validation error",
                content = @Content(schema = @Schema(implementation = ApiError.class))),
        @ApiResponse(
                responseCode = "403",
                description = "Vehicle belongs to another user",
                content = @Content(schema = @Schema(implementation = ApiError.class))),
        @ApiResponse(
                responseCode = "404",
                description = "Vehicle or photo not found",
                content = @Content(schema = @Schema(implementation = ApiError.class)))
})
public class VehiclePhotoController {

    private final VehiclePhotoService photos;

    public VehiclePhotoController(VehiclePhotoService photos) {
        this.photos = photos;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public VehiclePhotoResponse uploadPhoto(
            @PathVariable UUID vehicleId, @RequestParam("file") MultipartFile file) {
        return photos.uploadPhoto(vehicleId, file);
    }

    @GetMapping
    public VehiclePhotoListResponse listPhotos(@PathVariable UUID vehicleId) {
        return photos.listPhotos(vehicleId);
    }

    @DeleteMapping("/{photoId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deletePhoto(@PathVariable UUID vehicleId, @PathVariable UUID photoId) {
        photos.deletePhoto(vehicleId, photoId);
    }
}
