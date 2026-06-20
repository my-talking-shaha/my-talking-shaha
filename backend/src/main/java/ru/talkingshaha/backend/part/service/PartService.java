package ru.talkingshaha.backend.part.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import ru.talkingshaha.backend.common.error.ResourceNotFoundException;
import ru.talkingshaha.backend.part.dto.CreatePartRequest;
import ru.talkingshaha.backend.part.dto.PartListResponse;
import ru.talkingshaha.backend.part.dto.PartResponse;
import ru.talkingshaha.backend.part.dto.UpdatePartRequest;
import ru.talkingshaha.backend.part.model.Part;
import ru.talkingshaha.backend.part.repository.PartRepository;
import ru.talkingshaha.backend.prediction.dto.PartLifetimeRequest;
import ru.talkingshaha.backend.prediction.service.PartLifetimeService;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.service.VehicleService;

@Service
public class PartService {

    private final PartRepository parts;
    private final VehicleService vehicles;
    private final PartLifetimeService lifetimeService;

    public PartService(PartRepository parts, VehicleService vehicles, PartLifetimeService lifetimeService) {
        this.parts = parts;
        this.vehicles = vehicles;
        this.lifetimeService = lifetimeService;
    }

    @Transactional(readOnly = true)
    public PartListResponse listParts(UUID vehicleId) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        List<PartResponse> result =
                parts.findAllByVehicleOrderByInstalledAtDescNameAsc(vehicle).stream().map(this::toResponse).toList();
        return new PartListResponse(result);
    }

    @Transactional
    public PartResponse createPart(UUID vehicleId, CreatePartRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        Part part = new Part();
        part.setVehicle(vehicle);
        part.setName(request.name());
        part.setCategory(request.category());
        part.setInstalledAt(request.installedAt());
        part.setInstalledMileageKm(request.installedMileageKm());
        part.setExpectedLifetimeKm(request.expectedLifetimeKm());
        refreshLifetime(vehicle, part);
        return toResponse(parts.save(part));
    }

    @Transactional
    public PartResponse updatePart(UUID vehicleId, UUID partId, UpdatePartRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        Part part = parts.findByIdAndVehicle(partId, vehicle)
                .orElseThrow(() -> new ResourceNotFoundException("Part not found"));
        if (StringUtils.hasText(request.name())) {
            part.setName(request.name());
        }
        if (request.category() != null) {
            part.setCategory(request.category());
        }
        if (request.installedAt() != null) {
            part.setInstalledAt(request.installedAt());
        }
        if (request.installedMileageKm() != null) {
            part.setInstalledMileageKm(request.installedMileageKm());
        }
        if (request.expectedLifetimeKm() != null) {
            part.setExpectedLifetimeKm(request.expectedLifetimeKm());
        }
        refreshLifetime(vehicle, part);
        return toResponse(part);
    }

    private void refreshLifetime(Vehicle vehicle, Part part) {
        var lifetime = lifetimeService.calculate(new PartLifetimeRequest(
                vehicle.getMileageKm(), part.getInstalledMileageKm(), part.getExpectedLifetimeKm()));
        part.setRemainingKm(lifetime.remainingKm());
        part.setRemainingPercent(lifetime.remainingPercent());
        part.setStatus(lifetime.status());
    }

    private PartResponse toResponse(Part part) {
        return new PartResponse(
                part.getId(),
                part.getName(),
                part.getCategory(),
                part.getInstalledAt(),
                part.getInstalledMileageKm(),
                part.getExpectedLifetimeKm(),
                part.getRemainingKm(),
                part.getRemainingPercent(),
                part.getStatus());
    }
}