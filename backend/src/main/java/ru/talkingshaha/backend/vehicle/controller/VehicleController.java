package ru.talkingshaha.backend.vehicle.controller;

import java.util.List;
import java.util.UUID;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import ru.talkingshaha.backend.vehicle.dto.CreateVehicleRequest;
import ru.talkingshaha.backend.vehicle.dto.UpdateVehicleRequest;
import ru.talkingshaha.backend.vehicle.dto.VehicleDashboardResponse;
import ru.talkingshaha.backend.vehicle.dto.VehicleResponse;
import ru.talkingshaha.backend.vehicle.service.VehicleService;

/**
 * REST API for managing the current user's garage vehicles.
 *
 * <p>All endpoints are scoped to vehicles owned by the authenticated user; access to
 * another user's vehicle results in a {@code FORBIDDEN} error.
 */
@RestController
@RequestMapping("/api/v1/vehicles")
public class VehicleController {

    private final VehicleService vehicles;

    public VehicleController(VehicleService vehicles) {
        this.vehicles = vehicles;
    }

    /**
     * Lists all vehicles in the current user's garage, ordered by brand and model.
     *
     * @return the user's vehicles
     */
    @GetMapping
    public List<VehicleResponse> listVehicles() {
        return vehicles.listVehicles();
    }

    /**
     * Adds a new vehicle to the current user's garage.
     *
     * @param request the vehicle data to create
     * @return the created vehicle
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public VehicleResponse createVehicle(@Valid @RequestBody CreateVehicleRequest request) {
        return vehicles.createVehicle(request);
    }

    /**
     * Partially updates an existing vehicle. Only the non-null fields of the request are applied.
     *
     * @param vehicleId the vehicle identifier
     * @param request   the fields to update
     * @return the updated vehicle
     */
    @PatchMapping("/{vehicleId}")
    public VehicleResponse updateVehicle(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody UpdateVehicleRequest request) {
        return vehicles.updateVehicle(vehicleId, request);
    }

    /**
     * Deletes a vehicle together with its parts and timeline events.
     *
     * @param vehicleId the vehicle identifier
     */
    @DeleteMapping("/{vehicleId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteVehicle(@PathVariable UUID vehicleId) {
        vehicles.deleteVehicle(vehicleId);
    }

    /**
     * Returns the dashboard for a vehicle: the vehicle card, the parts maintenance
     * forecast, and recent timeline events.
     *
     * @param vehicleId the vehicle identifier
     * @return the vehicle dashboard
     */
    @GetMapping("/{vehicleId}/dashboard")
    public VehicleDashboardResponse dashboard(@PathVariable UUID vehicleId) {
        return vehicles.dashboard(vehicleId);
    }
}