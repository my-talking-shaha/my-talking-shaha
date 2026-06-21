package ru.talkingshaha.backend.timeline.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.common.model.BaseEvent;
import ru.talkingshaha.backend.timeline.dto.CreateMaintenanceEventRequest;
import ru.talkingshaha.backend.timeline.dto.CreateRefuelEventRequest;
import ru.talkingshaha.backend.timeline.dto.CreateTripEventRequest;
import ru.talkingshaha.backend.timeline.dto.TimelineEventListResponse;
import ru.talkingshaha.backend.timeline.dto.TimelineEventResponse;
import ru.talkingshaha.backend.timeline.model.MaintenanceEvent;
import ru.talkingshaha.backend.timeline.model.RefuelEvent;
import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.timeline.model.TripEvent;
import ru.talkingshaha.backend.timeline.repository.MaintenanceEventRepository;
import ru.talkingshaha.backend.timeline.repository.RefuelEventRepository;
import ru.talkingshaha.backend.timeline.repository.TimelineEventRepository;
import ru.talkingshaha.backend.timeline.repository.TripEventRepository;
import ru.talkingshaha.backend.part.service.PartService;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.service.VehicleService;

@Service
public class TimelineEventService {

    private final TimelineEventRepository events;
    private final TripEventRepository trips;
    private final RefuelEventRepository refuels;
    private final MaintenanceEventRepository maintenances;
    private final VehicleService vehicles;
    private final PartService parts;

    public TimelineEventService(
            TimelineEventRepository events,
            TripEventRepository trips,
            RefuelEventRepository refuels,
            MaintenanceEventRepository maintenances,
            VehicleService vehicles,
            PartService parts) {
        this.events = events;
        this.trips = trips;
        this.refuels = refuels;
        this.maintenances = maintenances;
        this.vehicles = vehicles;
        this.parts = parts;
    }

    @Transactional(readOnly = true)
    public TimelineEventListResponse getEvents(UUID vehicleId, TimelineEventType type) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        List<BaseEvent> list = type != null
                ? events.findAllByVehicleAndTypeOrderByEventDateTimeDesc(vehicle, type)
                : events.findAllByVehicleOrderByEventDateTimeDesc(vehicle);
        return new TimelineEventListResponse(list.stream().map(this::toResponse).toList());
    }

    @Transactional
    public TimelineEventResponse createRefuelEvent(UUID vehicleId, CreateRefuelEventRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        validateMileage(vehicle, request.mileageKm());

        RefuelEvent event = new RefuelEvent();
        event.setVehicle(vehicle);
        event.setType(TimelineEventType.REFUEL);
        event.setEventDateTime(request.eventDateTime());
        event.setMileageKm(request.mileageKm());
        event.setLiters(request.liters());
        event.setCost(request.cost());
        event.setFuelType(request.fuelType());
        event.setFuelName(request.fuelName());
        event.setStationName(request.stationName());

        updateVehicleMileage(vehicle, request.mileageKm());
        return toResponse(refuels.save(event));
    }

    @Transactional
    public TimelineEventResponse createTripEvent(UUID vehicleId, CreateTripEventRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        validateMileage(vehicle, request.endMileageKm());

        if (request.startMileageKm() != null && request.endMileageKm() < request.startMileageKm()) {
            throw new IllegalArgumentException("End mileage must be >= start mileage");
        }

        TripEvent event = new TripEvent();
        event.setVehicle(vehicle);
        event.setType(TimelineEventType.TRIP);
        event.setEventDateTime(request.eventDateTime());
        event.setStartMileageKm(request.startMileageKm());
        event.setEndMileageKm(request.endMileageKm());
        event.setRoute(request.route());
        event.setDurationMinutes(request.durationMinutes());
        event.setCost(request.cost());

        updateVehicleMileage(vehicle, request.endMileageKm());
        return toResponse(trips.save(event));
    }

    @Transactional
    public TimelineEventResponse createMaintenanceEvent(UUID vehicleId, CreateMaintenanceEventRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        validateMileage(vehicle, request.mileageKm());

        MaintenanceEvent event = new MaintenanceEvent();
        event.setVehicle(vehicle);
        event.setType(TimelineEventType.MAINTENANCE);
        event.setEventDateTime(request.eventDateTime());
        event.setName(request.name());
        event.setDescription(request.description());
        event.setMileageKm(request.mileageKm());
        event.setCost(request.cost());
        if (request.photoUrls() != null) {
            event.getPhotoUrls().addAll(request.photoUrls());
        }

        updateVehicleMileage(vehicle, request.mileageKm());
        return toResponse(maintenances.save(event));
    }

    private void validateMileage(Vehicle vehicle, Integer mileageKm) {
        if (mileageKm != null && mileageKm < vehicle.getMileageKm()) {
            throw new IllegalArgumentException(
                    "Mileage %d is less than current vehicle mileage %d"
                            .formatted(mileageKm, vehicle.getMileageKm()));
        }
    }

    private void updateVehicleMileage(Vehicle vehicle, Integer mileageKm) {
        if (mileageKm != null && mileageKm > vehicle.getMileageKm()) {
            vehicle.setMileageKm(mileageKm);
            parts.refreshPartsForVehicle(vehicle);
        }
    }

    private TimelineEventResponse toResponse(BaseEvent event) {
        return switch (event) {
            case RefuelEvent r -> new TimelineEventResponse(
                    r.getId(),
                    r.getType(),
                    "Refill " + (r.getFuelName() != null ? r.getFuelName() : r.getFuelType().name()),
                    r.getEventDateTime(),
                    r.getCost(),
                    r.getMileageKm(),
                    r.getLiters(),
                    r.getFuelType(),
                    r.getFuelName(),
                    r.getStationName(),
                    null, null, null, null, null,
                    null, null, null);
            case TripEvent t -> {
                Integer distance = (t.getStartMileageKm() != null && t.getEndMileageKm() != null)
                        ? t.getEndMileageKm() - t.getStartMileageKm()
                        : null;
                yield new TimelineEventResponse(
                        t.getId(),
                        t.getType(),
                        "Trip",
                        t.getEventDateTime(),
                        t.getCost(),
                        t.getEndMileageKm(),
                        null, null, null, null,
                        t.getStartMileageKm(),
                        t.getEndMileageKm(),
                        distance,
                        t.getRoute(),
                        t.getDurationMinutes(),
                        null, null, null);
            }
            case MaintenanceEvent m -> new Time lineEventResponse(
                    m.getId(),
                    m.getType(),
                    m.getName(),
                    m.getEventDateTime(),
                    m.getCost(),
                    m.getMileageKm(),
                    null, null, null, null,
                    null, null, null, null, null,
                    m.getName(),
                    m.getDescription(),
                    m.getPhotoUrls());
            default -> throw new IllegalStateException("Unknown event type: " + event.getClass());
        };
    }
}
