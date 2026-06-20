package ru.talkingshaha.backend.vehicle.service;

import java.time.OffsetDateTime;
import java.time.Year;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.common.error.ResourceNotFoundException;
import ru.talkingshaha.backend.part.dto.PartResponse;
import ru.talkingshaha.backend.part.model.PartStatus;
import ru.talkingshaha.backend.part.repository.PartRepository;
import ru.talkingshaha.backend.user.model.AppUser;
import ru.talkingshaha.backend.user.service.CurrentUserService;
import ru.talkingshaha.backend.vehicle.dto.CreateVehicleRequest;
import ru.talkingshaha.backend.vehicle.dto.VehicleDashboardResponse;
import ru.talkingshaha.backend.vehicle.dto.VehicleResponse;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.repository.VehicleRepository;

@Service
public class VehicleService {

    private final VehicleRepository vehicles;
    private final PartRepository parts;
    private final CurrentUserService currentUserService;

    public VehicleService(VehicleRepository vehicles, PartRepository parts, CurrentUserService currentUserService) {
        this.vehicles = vehicles;
        this.parts = parts;
        this.currentUserService = currentUserService;
    }

    @Transactional(readOnly = true)
    public List<VehicleResponse> listVehicles() {
        AppUser owner = currentUserService.currentUser();
        return vehicles.findAllByOwnerOrderByBrandAscModelAsc(owner).stream().map(this::toResponse).toList();
    }

    @Transactional
    public VehicleResponse createVehicle(CreateVehicleRequest request) {
        validateProductionYear(request.productionYear());
        Vehicle vehicle = new Vehicle();
        vehicle.setOwner(currentUserService.currentUser());
        vehicle.setBrand(request.brand());
        vehicle.setModel(request.model());
        vehicle.setProductionYear(request.productionYear());
        vehicle.setColor(request.color());
        vehicle.setMileageKm(request.mileageKm());
        vehicle.setFuelType(request.fuelType());
        vehicle.setEngineDescription(request.engineDescription());
        vehicle.setVin(request.vin());
        vehicle.setPhotoUrl(request.photoUrl());
        return toResponse(vehicles.save(vehicle));
    }

    @Transactional(readOnly = true)
    public VehicleDashboardResponse dashboard(UUID vehicleId) {
        Vehicle vehicle = requireOwnedVehicle(vehicleId);
        List<PartResponse> forecastParts =
                parts.findAllByVehicleOrderByInstalledAtDescNameAsc(vehicle).stream().map(this::toPartResponse).toList();
        PartStatus overallStatus = overallStatus(forecastParts);
        Integer nextServiceInKm = forecastParts.stream()
                .map(PartResponse::remainingKm)
                .filter(value -> value != null && value >= 0)
                .min(Comparator.naturalOrder())
                .orElse(null);
        var forecast = new VehicleDashboardResponse.MaintenanceForecast(
                overallStatus, nextServiceInKm, OffsetDateTime.now(), forecastParts);
        return new VehicleDashboardResponse(toResponse(vehicle), forecast, List.of());
    }

    @Transactional(readOnly = true)
    public Vehicle requireOwnedVehicle(UUID vehicleId) {
        AppUser owner = currentUserService.currentUser();
        return vehicles.findByIdAndOwner(vehicleId, owner)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found"));
    }

    private void validateProductionYear(Integer productionYear) {
        if (productionYear > Year.now().getValue()) {
            throw new IllegalArgumentException("Vehicle year must not be greater than current year");
        }
    }

    private VehicleResponse toResponse(Vehicle vehicle) {
        return new VehicleResponse(
                vehicle.getId(),
                vehicle.getBrand(),
                vehicle.getModel(),
                vehicle.getProductionYear(),
                vehicle.getColor(),
                vehicle.getMileageKm(),
                vehicle.getFuelType(),
                vehicle.getEngineDescription(),
                vehicle.getVin(),
                vehicle.getPhotoUrl());
    }

    private PartResponse toPartResponse(ru.talkingshaha.backend.part.model.Part part) {
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

    private PartStatus overallStatus(List<PartResponse> parts) {
        if (parts.stream().anyMatch(part -> part.status() == PartStatus.CRITICAL)) {
            return PartStatus.CRITICAL;
        }
        if (parts.stream().anyMatch(part -> part.status() == PartStatus.ATTENTION)) {
            return PartStatus.ATTENTION;
        }
        if (parts.isEmpty() || parts.stream().allMatch(part -> part.status() == PartStatus.UNKNOWN)) {
            return PartStatus.UNKNOWN;
        }
        return PartStatus.OK;
    }
}