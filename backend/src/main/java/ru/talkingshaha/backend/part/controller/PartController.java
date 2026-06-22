package ru.talkingshaha.backend.part.controller;

import java.util.UUID;

import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import ru.talkingshaha.backend.common.error.ApiError;
import ru.talkingshaha.backend.part.dto.CreatePartRequest;
import ru.talkingshaha.backend.part.dto.PartListResponse;
import ru.talkingshaha.backend.part.dto.PartResponse;
import ru.talkingshaha.backend.part.dto.UpdatePartRequest;
import ru.talkingshaha.backend.part.service.PartService;

@RestController
@RequestMapping("/api/v1/vehicles/{vehicleId}/parts")
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
                description = "Vehicle or part not found",
                content = @Content(schema = @Schema(implementation = ApiError.class)))
})
public class PartController {

    private final PartService parts;

    public PartController(PartService parts) {
        this.parts = parts;
    }

    @GetMapping
    public PartListResponse listParts(@PathVariable UUID vehicleId) {
        return parts.listParts(vehicleId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PartResponse createPart(@PathVariable UUID vehicleId, @Valid @RequestBody CreatePartRequest request) {
        return parts.createPart(vehicleId, request);
    }

    @PatchMapping("/{partId}")
    public PartResponse updatePart(
            @PathVariable UUID vehicleId, @PathVariable UUID partId, @Valid @RequestBody UpdatePartRequest request) {
        return parts.updatePart(vehicleId, partId, request);
    }
}