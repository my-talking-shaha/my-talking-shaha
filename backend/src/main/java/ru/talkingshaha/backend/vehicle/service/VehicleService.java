package ru.talkingshaha.backend.vehicle.service;

import java.time.OffsetDateTime;
import java.time.Year;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.common.error.ForbiddenException;
import ru.talkingshaha.backend.common.error.ResourceNotFoundException;
import ru.talkingshaha.backend.common.model.BaseEvent;
import ru.talkingshaha.backend.part.dto.PartResponse;
import ru.talkingshaha.backend.part.model.PartStatus;
import ru.talkingshaha.backend.part.repository.PartRepository;
import ru.talkingshaha.backend.timeline.model.MaintenanceEvent;
import ru.talkingshaha.backend.timeline.model.RefuelEvent;
import ru.talkingshaha.backend.timeline.model.TripEvent;
import ru.talkingshaha.backend.user.model.AppUser;
import ru.talkingshaha.backend.user.service.CurrentUserService;
import org.springframework.util.StringUtils;
import ru.talkingshaha.backend.timeline.repository.TimelineEventRepository;
import ru.talkingshaha.backend.vehicle.dto.CreateVehicleRequest;
import ru.talkingshaha.backend.vehicle.dto.UpdateVehicleRequest;
import ru.talkingshaha.backend.vehicle.dto.VehicleDashboardResponse;
import ru.talkingshaha.backend.vehicle.dto.VehicleDashboardResponse.RecentEventResponse;
import ru.talkingshaha.backend.vehicle.dto.VehicleResponse;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.repository.VehicleRepository;

/**
 * Application service for garage vehicles.
 *
 * <p>Every operation is scoped to the authenticated owner; access to another user's vehicle
 * raises {@link ForbiddenException} and a missing vehicle raises {@link ResourceNotFoundException}.
 */
@Service
public class VehicleService {

    /** Maximum number of timeline events shown on the dashboard. */
    private static final int RECENT_EVENTS_LIMIT = 5;

    private final VehicleRepository vehicles;
    private final PartRepository parts;
    private final TimelineEventRepository events;
    private final CurrentUserService currentUserService;

    public VehicleService(
            VehicleRepository vehicles,
            PartRepository parts,
            TimelineEventRepository events,
            CurrentUserService currentUserService) {
        this.vehicles = vehicles;
        this.parts = parts;
        this.events = events;
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

    @Transactional
    public VehicleResponse updateVehicle(UUID vehicleId, UpdateVehicleRequest request) {
        Vehicle vehicle = requireOwnedVehicle(vehicleId);
        if (StringUtils.hasText(request.brand())) vehicle.setBrand(request.brand());
        if (StringUtils.hasText(request.model())) vehicle.setModel(request.model());
        if (request.productionYear() != null) {
            validateProductionYear(request.productionYear());
            vehicle.setProductionYear(request.productionYear());
        }
        if (request.color() != null) vehicle.setColor(request.color());
        if (request.mileageKm() != null) vehicle.setMileageKm(request.mileageKm());
        if (request.fuelType() != null) vehicle.setFuelType(request.fuelType());
        if (request.engineDescription() != null) vehicle.setEngineDescription(request.engineDescription());
        if (request.vin() != null) vehicle.setVin(request.vin());
        if (request.photoUrl() != null) vehicle.setPhotoUrl(request.photoUrl());
        return toResponse(vehicle);
    }

    /**
     * Deletes a vehicle and cascades the removal of its timeline events and parts.
     *
     * @param vehicleId the vehicle identifier
     */
    @Transactional
    public void deleteVehicle(UUID vehicleId) {
        Vehicle vehicle = requireOwnedVehicle(vehicleId);
        events.deleteAll(events.findAllByVehicleOrderByEventDateTimeDesc(vehicle));
        parts.deleteAll(parts.findAllByVehicleOrderByInstalledAtDescNameAsc(vehicle));
        vehicles.delete(vehicle);
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
        return new VehicleDashboardResponse(toResponse(vehicle), forecast, recentEvents(vehicle));
    }

    private List<RecentEventResponse> recentEvents(Vehicle vehicle) {
        return events.findAllByVehicleOrderByEventDateTimeDesc(vehicle).stream()
                .limit(RECENT_EVENTS_LIMIT)
                .map(this::toRecentEvent)
                .toList();
    }

    private RecentEventResponse toRecentEvent(BaseEvent event) {
        String title;
        String subtitle;
        switch (event) {
            case RefuelEvent r -> {
                title = "Refill " + (r.getFuelName() != null ? r.getFuelName() : r.getFuelType().name());
                subtitle = r.getLiters() != null ? r.getLiters() + " L" : null;
            }
            case TripEvent t -> {
                title = "Trip";
                subtitle = t.getRoute();
            }
            case MaintenanceEvent m -> {
                title = m.getName();
                subtitle = m.getDescription();
            }
            default -> throw new IllegalStateException("Unknown event type: " + event.getClass());
        }
        return new RecentEventResponse(
                event.getId().toString(), event.getType().name(), title, subtitle, event.getEventDateTime());
    }

    /**
     * Loads a vehicle and verifies it belongs to the current user.
     *
     * @param vehicleId the vehicle identifier
     * @return the owned vehicle
     * @throws ResourceNotFoundException if no vehicle with the given id exists
     * @throws ForbiddenException        if the vehicle belongs to another user
     */
    @Transactional(readOnly = true)
    public Vehicle requireOwnedVehicle(UUID vehicleId) {
        AppUser owner = currentUserService.currentUser();
        Vehicle vehicle = vehicles.findById(vehicleId)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found"));
        if (!vehicle.getOwner().getId().equals(owner.getId())) {
            throw new ForbiddenException("Vehicle belongs to another user");
        }
        return vehicle;
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