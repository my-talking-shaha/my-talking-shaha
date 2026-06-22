package ru.talkingshaha.backend.part.controller;

import java.util.UUID;

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
import ru.talkingshaha.backend.part.dto.CreatePartRequest;
import ru.talkingshaha.backend.part.dto.PartListResponse;
import ru.talkingshaha.backend.part.dto.PartResponse;
import ru.talkingshaha.backend.part.dto.UpdatePartRequest;
import ru.talkingshaha.backend.part.service.PartService;

/**
 * REST API for the installed parts of a vehicle.
 *
 * <p>Each part carries a computed remaining lifetime (kilometres, percent, and status)
 * derived from the vehicle's current mileage.
 */
@RestController
@RequestMapping("/api/v1/vehicles/{vehicleId}/parts")
public class PartController {

    private final PartService parts;

    public PartController(PartService parts) {
        this.parts = parts;
    }

    /**
     * Lists the parts installed on a vehicle with their calculated lifetime.
     *
     * @param vehicleId the vehicle identifier
     * @return the installed parts
     */
    @GetMapping
    public PartListResponse listParts(@PathVariable UUID vehicleId) {
        return parts.listParts(vehicleId);
    }

    /**
     * Registers a new installed part and computes its initial lifetime.
     *
     * @param vehicleId the vehicle identifier
     * @param request   the part data
     * @return the created part
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PartResponse createPart(@PathVariable UUID vehicleId, @Valid @RequestBody CreatePartRequest request) {
        return parts.createPart(vehicleId, request);
    }

    /**
     * Partially updates an installed part and recalculates its lifetime.
     * Only the non-null fields of the request are applied.
     *
     * @param vehicleId the vehicle identifier
     * @param partId    the part identifier
     * @param request   the fields to update
     * @return the updated part
     */
    @PatchMapping("/{partId}")
    public PartResponse updatePart(
            @PathVariable UUID vehicleId, @PathVariable UUID partId, @Valid @RequestBody UpdatePartRequest request) {
        return parts.updatePart(vehicleId, partId, request);
    }
}