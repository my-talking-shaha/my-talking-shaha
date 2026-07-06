package ru.talkingshaha.backend.timeline.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Validator;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.common.error.ResourceNotFoundException;
import ru.talkingshaha.backend.common.model.BaseEvent;
import ru.talkingshaha.backend.timeline.dto.CreateMaintenanceEventRequest;
import ru.talkingshaha.backend.timeline.dto.CreatePartEventRequest;
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
    private final ObjectMapper objectMapper;
    private final Validator validator;

    public TimelineEventService(
            TimelineEventRepository events,
            TripEventRepository trips,
            RefuelEventRepository refuels,
            MaintenanceEventRepository maintenances,
            VehicleService vehicles,
            PartService parts,
            ObjectMapper objectMapper,
            Validator validator) {
        this.events = events;
        this.trips = trips;
        this.refuels = refuels;
        this.maintenances = maintenances;
        this.vehicles = vehicles;
        this.parts = parts;
        this.objectMapper = objectMapper;
        this.validator = validator;
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
        event.setTitle(request.title());
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
        event.setTitle(request.title());
        event.setStartMileageKm(request.startMileageKm());
        event.setEndMileageKm(request.endMileageKm());
        event.setRoute(request.route());
        event.setDurationMinutes(request.durationMinutes());
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

    @Transactional
    public TimelineEventResponse createPartEvent(UUID vehicleId, CreatePartEventRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        validateMileage(vehicle, request.mileageKm());
        MaintenanceEvent event = new MaintenanceEvent();
        event.setVehicle(vehicle);
        event.setType(TimelineEventType.PART_REPLACEMENT);
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

    @Transactional
    public TimelineEventResponse updateEvent(UUID vehicleId, UUID eventId, JsonNode body) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        BaseEvent event = events.findByIdAndVehicle(eventId, vehicle)
                .orElseThrow(() -> new ResourceNotFoundException("Timeline event not found"));
        switch (event) {
            case RefuelEvent refuel -> applyRefuelUpdate(refuel, convertAndValidate(body, CreateRefuelEventRequest.class));
            case TripEvent trip -> applyTripUpdate(trip, convertAndValidate(body, CreateTripEventRequest.class));
            case MaintenanceEvent maintenance ->
                    applyMaintenanceUpdate(maintenance, convertAndValidate(body, CreateMaintenanceEventRequest.class));
            default -> throw new IllegalStateException("Unknown event type: " + event.getClass());
        }
        updateVehicleMileage(vehicle, eventMileage(event));
        return toResponse(event);
    }

    @Transactional
    public void deleteEvent(UUID vehicleId, UUID eventId) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        BaseEvent event = events.findByIdAndVehicle(eventId, vehicle)
                .orElseThrow(() -> new ResourceNotFoundException("Timeline event not found"));
        events.delete(event);
    }

    private <T> T convertAndValidate(JsonNode body, Class<T> requestType) {
        T request;
        try {
            request = objectMapper.convertValue(body, requestType);
        } catch (IllegalArgumentException exception) {
            throw new IllegalArgumentException("Request contains invalid fields");
        }
        Set<ConstraintViolation<T>> violations = validator.validate(request);
        if (!violations.isEmpty()) {
            throw new ConstraintViolationException(violations);
        }
        return request;
    }

    private void applyRefuelUpdate(RefuelEvent event, CreateRefuelEventRequest request) {
        event.setEventDateTime(request.eventDateTime());
        event.setTitle(request.title());
        event.setMileageKm(request.mileageKm());
        event.setLiters(request.liters());
        event.setCost(request.cost());
        event.setFuelType(request.fuelType());
        event.setFuelName(request.fuelName());
        event.setStationName(request.stationName());
    }

    private void applyTripUpdate(TripEvent event, CreateTripEventRequest request) {
        if (request.startMileageKm() != null && request.endMileageKm() < request.startMileageKm()) {
            throw new IllegalArgumentException("End mileage must be >= start mileage");
        }
        event.setEventDateTime(request.eventDateTime());
        event.setTitle(request.title());
        event.setStartMileageKm(request.startMileageKm());
        event.setEndMileageKm(request.endMileageKm());
        event.setRoute(request.route());
        event.setDurationMinutes(request.durationMinutes());
    }

    private void applyMaintenanceUpdate(MaintenanceEvent event, CreateMaintenanceEventRequest request) {
        event.setEventDateTime(request.eventDateTime());
        event.setMileageKm(request.mileageKm());
        event.setName(request.name());
        event.setDescription(request.description());
        event.setCost(request.cost());
        if (request.photoUrls() != null) {
            event.getPhotoUrls().clear();
            event.getPhotoUrls().addAll(request.photoUrls());
        }
    }

    private Integer eventMileage(BaseEvent event) {
        return switch (event) {
            case RefuelEvent refuel -> refuel.getMileageKm();
            case TripEvent trip -> trip.getEndMileageKm();
            case MaintenanceEvent maintenance -> maintenance.getMileageKm();
            default -> null;
        };
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
                    r.getTitle(),
                    r.getEventDateTime(),
                    r.getCost(),
                    r.getMileageKm(),
                    r.getLiters(),
                    r.getFuelType(),
                    r.getFuelName(),
                    r.getStationName(),
                    null, null, null, null, null,
                    null,
                    null, null, null);
            case TripEvent t -> {
                Integer distance = (t.getStartMileageKm() != null && t.getEndMileageKm() != null)
                        ? t.getEndMileageKm() - t.getStartMileageKm()
                        : null;
                BigDecimal averageConsumption = averageFuelConsumptionLitersPerKm(t.getVehicle());
                yield new TimelineEventResponse(
                        t.getId(),
                        t.getType(),
                        t.getTitle(),
                        t.getEventDateTime(),
                        null,
                        t.getEndMileageKm(),
                        null, null, null, null,
                        t.getStartMileageKm(),
                        t.getEndMileageKm(),
                        distance,
                        t.getRoute(),
                        t.getDurationMinutes(),
                        averageConsumption,
                        null, null, null);
            }
            case MaintenanceEvent m -> new TimelineEventResponse(
                    m.getId(),
                    m.getType(),
                    m.getName(),
                    m.getEventDateTime(),
                    m.getCost(),
                    m.getMileageKm(),
                    null, null, null, null,
                    null, null, null, null, null,
                    null,
                    m.getName(),
                    m.getDescription(),
                    List.copyOf(m.getPhotoUrls()));
            default -> throw new IllegalStateException("Unknown event type: " + event.getClass());
        };
    }

    private BigDecimal averageFuelConsumptionLitersPerKm(Vehicle vehicle) {
        BigDecimal liters = events.findAllByVehicleAndTypeOrderByEventDateTimeDesc(vehicle, TimelineEventType.REFUEL)
                .stream()
                .filter(RefuelEvent.class::isInstance)
                .map(RefuelEvent.class::cast)
                .map(RefuelEvent::getLiters)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        int distanceKm = events.findAllByVehicleAndTypeOrderByEventDateTimeDesc(vehicle, TimelineEventType.TRIP)
                .stream()
                .filter(TripEvent.class::isInstance)
                .map(TripEvent.class::cast)
                .mapToInt(trip -> trip.getStartMileageKm() == null
                        ? 0
                        : Math.max(0, trip.getEndMileageKm() - trip.getStartMileageKm()))
                .sum();
        if (distanceKm == 0 || liters.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        return liters.divide(BigDecimal.valueOf(distanceKm), 4, RoundingMode.HALF_UP);
    }
}
