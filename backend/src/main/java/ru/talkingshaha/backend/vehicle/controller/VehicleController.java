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

@RestController
@RequestMapping("/api/v1/vehicles")
public class VehicleController {

    private final VehicleService vehicles;

    public VehicleController(VehicleService vehicles) {
        this.vehicles = vehicles;
    }

    @GetMapping
    public List<VehicleResponse> listVehicles() {
        return vehicles.listVehicles();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public VehicleResponse createVehicle(@Valid @RequestBody CreateVehicleRequest request) {
        return vehicles.createVehicle(request);
    }

    @PatchMapping("/{vehicleId}")
    public VehicleResponse updateVehicle(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody UpdateVehicleRequest request) {
        return vehicles.updateVehicle(vehicleId, request);
    }

    @DeleteMapping("/{vehicleId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteVehicle(@PathVariable UUID vehicleId) {
        vehicles.deleteVehicle(vehicleId);
    }

    @GetMapping("/{vehicleId}/dashboard")
    public VehicleDashboardResponse dashboard(@PathVariable UUID vehicleId) {
        return vehicles.dashboard(vehicleId);
    }
}