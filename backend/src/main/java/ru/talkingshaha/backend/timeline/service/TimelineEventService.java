package ru.talkingshaha.backend.timeline.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Validator;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.common.model.BaseEvent;
import ru.talkingshaha.backend.common.error.ResourceNotFoundException;
import ru.talkingshaha.backend.chat.model.ChatSession;
import ru.talkingshaha.backend.timeline.dto.CreateMaintenanceEventRequest;
import ru.talkingshaha.backend.timeline.dto.CreatePartEventRequest;
import ru.talkingshaha.backend.timeline.dto.CreateRefuelEventRequest;
import ru.talkingshaha.backend.timeline.dto.CreateTripEventRequest;
import ru.talkingshaha.backend.timeline.dto.TimelineEventListResponse;
import ru.talkingshaha.backend.timeline.dto.TimelineEventResponse;
import ru.talkingshaha.backend.timeline.model.MaintenanceEvent;
import ru.talkingshaha.backend.timeline.model.RefuelEvent;
import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.timeline.model.TripCompletionStatus;
import ru.talkingshaha.backend.timeline.model.TripEvent;
import ru.talkingshaha.backend.timeline.repository.MaintenanceEventRepository;
import ru.talkingshaha.backend.timeline.repository.RefuelEventRepository;
import ru.talkingshaha.backend.timeline.repository.TimelineEventRepository;
import ru.talkingshaha.backend.timeline.repository.TripEventRepository;
import ru.talkingshaha.backend.part.service.PartService;
import ru.talkingshaha.backend.vehicle.model.FuelType;
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
        TimelineEventType type = isRechargeRequest(vehicle, request)
                ? TimelineEventType.RECHARGE
                : TimelineEventType.REFUEL;
        return createFuelEvent(vehicle, request, type);
    }

    @Transactional
    public TimelineEventResponse createRechargeEvent(UUID vehicleId, CreateRefuelEventRequest request) {
        if (request.fuelType() != FuelType.ELECTRIC) {
            throw new IllegalArgumentException("Recharge events must use ELECTRIC fuel type");
        }
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        return createFuelEvent(vehicle, request, TimelineEventType.RECHARGE);
    }

    private TimelineEventResponse createFuelEvent(Vehicle vehicle, CreateRefuelEventRequest request, TimelineEventType type) {
        validateMileage(vehicle, request.mileageKm());
        BigDecimal amount = fuelAmount(request, type);
        RefuelEvent event = new RefuelEvent();
        event.setVehicle(vehicle);
        event.setType(type);
        event.setEventDateTime(request.eventDateTime());
        event.setTitle(request.title());
        event.setMileageKm(request.mileageKm());
        event.setLiters(amount);
        event.setCost(request.cost());
        event.setFuelType(type == TimelineEventType.RECHARGE ? FuelType.ELECTRIC : request.fuelType());
        event.setFuelName(request.fuelName());
        event.setStationName(request.stationName());
        updateVehicleMileage(vehicle, request.mileageKm());
        return toResponse(refuels.save(event));
    }

    private boolean isRechargeRequest(Vehicle vehicle, CreateRefuelEventRequest request) {
        if (request.fuelType() == FuelType.ELECTRIC) {
            return true;
        }
        return vehicle.getFuelType() == FuelType.ELECTRIC;
    }

    private BigDecimal fuelAmount(CreateRefuelEventRequest request, TimelineEventType type) {
        if (type == TimelineEventType.RECHARGE) {
            if (request.kwh() != null && request.liters() != null && request.kwh().compareTo(request.liters()) != 0) {
                throw new IllegalArgumentException("Recharge kWh must match legacy liters when both are provided");
            }
            BigDecimal amount = request.kwh() != null ? request.kwh() : request.liters();
            if (amount == null) {
                throw new IllegalArgumentException("Recharge kWh must be provided");
            }
            return amount;
        }
        if (request.liters() == null) {
            throw new IllegalArgumentException("Refuel liters must be provided");
        }
        return request.liters();
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
        if (request.startMileageKm() != null && request.endMileageKm() != null) {
            event.setDistanceKm(request.endMileageKm() - request.startMileageKm());
        }
        event.setRoute(request.route());
        event.setDurationMinutes(request.durationMinutes());
        event.setEndedAt(request.eventDateTime().plusMinutes(request.durationMinutes()));
        event.setStatus(TripCompletionStatus.COMPLETE);
        updateVehicleMileage(vehicle, request.endMileageKm());
        return toResponse(trips.save(event));
    }

    @Transactional
    public TimelineEventResponse startChatTrip(UUID vehicleId, ChatSession session, OffsetDateTime startedAt, String notes) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        TripEvent event = new TripEvent();
        event.setVehicle(vehicle);
        event.setType(TimelineEventType.TRIP);
        event.setTitle("Поездка");
        event.setEventDateTime(startedAt == null ? OffsetDateTime.now() : startedAt);
        event.setStartMileageKm(vehicle.getMileageKm());
        event.setNotes(notes);
        event.setStatus(TripCompletionStatus.IN_PROGRESS);
        event.setChatSession(session);
        return toResponse(trips.save(event));
    }

    @Transactional
    public TimelineEventResponse updateChatTrip(UUID vehicleId, UUID tripId, ChatSession session, TripUpdate update) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        TripEvent event = trips.findByIdAndVehicle(tripId, vehicle)
                .orElseThrow(() -> new ResourceNotFoundException("Trip not found"));
        if (event.getChatSession() != null && !event.getChatSession().getId().equals(session.getId())) {
            throw new IllegalArgumentException("Trip belongs to another chat session");
        }
        event.setChatSession(session);
        if (update.endedAt() != null) {
            event.setEndedAt(update.endedAt());
        }
        if (update.distanceKm() != null) {
            if (update.distanceKm() < 0) {
                throw new IllegalArgumentException("Distance must be greater than or equal to 0");
            }
            event.setDistanceKm(update.distanceKm());
            if (event.getStartMileageKm() != null) {
                event.setEndMileageKm(event.getStartMileageKm() + update.distanceKm());
            }
        }
        if (update.durationMinutes() != null) {
            if (update.durationMinutes() <= 0) {
                throw new IllegalArgumentException("Duration must be greater than 0");
            }
            event.setDurationMinutes(update.durationMinutes());
        }
        if (update.fuelLiters() != null) {
            if (update.fuelLiters().compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("Fuel amount must be greater than 0");
            }
            event.setFuelLiters(update.fuelLiters());
        }
        if (update.notes() != null && !update.notes().isBlank()) {
            event.setNotes(update.notes());
            if (event.getRoute() == null || event.getRoute().isBlank()) {
                event.setRoute(update.notes());
            }
        }
        event.setStatus(missingRequiredTripFields(event).isEmpty()
                ? TripCompletionStatus.COMPLETE
                : TripCompletionStatus.PARTIAL);
        updateVehicleMileage(vehicle, event.getEndMileageKm());
        return toResponse(event);
    }

    @Transactional(readOnly = true)
    public Optional<UUID> activeChatTripId(ChatSession session) {
        return trips.findTopByChatSessionAndStatusOrderByEventDateTimeDesc(session, TripCompletionStatus.IN_PROGRESS)
                .map(TripEvent::getId);
    }

    @Transactional(readOnly = true)
    public List<String> missingRequiredTripFields(UUID vehicleId, UUID tripId) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        TripEvent event = trips.findByIdAndVehicle(tripId, vehicle)
                .orElseThrow(() -> new ResourceNotFoundException("Trip not found"));
        return missingRequiredTripFields(event);
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
        event.setLiters(fuelAmount(request, event.getType()));
        event.setCost(request.cost());
        event.setFuelType(event.getType() == TimelineEventType.RECHARGE ? FuelType.ELECTRIC : request.fuelType());
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
                    r.getType() == TimelineEventType.RECHARGE ? r.getLiters() : null,
                    r.getFuelType(),
                    r.getFuelName(),
                    r.getStationName(),
                    null, null, null, null, null,
                    null,
                    null, null, null,
                    null, null, null, null);
            case TripEvent t -> {
                Integer distance = t.getDistanceKm() != null
                        ? t.getDistanceKm()
                        : (t.getStartMileageKm() != null && t.getEndMileageKm() != null)
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
                        null, null, null, null, null,
                        t.getStartMileageKm(),
                        t.getEndMileageKm(),
                        distance,
                        t.getRoute(),
                        t.getDurationMinutes(),
                        averageConsumption,
                        null, null, null,
                        t.getEndedAt(), t.getFuelLiters(), t.getNotes(), t.getStatus());
            }
            case MaintenanceEvent m -> new TimelineEventResponse(
                    m.getId(),
                    m.getType(),
                    m.getName(),
                    m.getEventDateTime(),
                    m.getCost(),
                    m.getMileageKm(),
                    null, null, null, null, null,
                    null, null, null, null, null,
                    null,
                    m.getName(),
                    m.getDescription(),
                    List.copyOf(m.getPhotoUrls()),
                    null, null, null, null);
            default -> throw new IllegalStateException("Unknown event type: " + event.getClass());
        };
    }

    private BigDecimal averageFuelConsumptionLitersPerKm(Vehicle vehicle) {
        BigDecimal liters = events.findAllByVehicleOrderByEventDateTimeDesc(vehicle)
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
                        ? Math.max(0, trip.getDistanceKm() == null ? 0 : trip.getDistanceKm())
                        : Math.max(0, trip.getEndMileageKm() == null
                                ? trip.getDistanceKm() == null ? 0 : trip.getDistanceKm()
                                : trip.getEndMileageKm() - trip.getStartMileageKm()))
                .sum();
        if (distanceKm == 0 || liters.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        return liters.divide(BigDecimal.valueOf(distanceKm), 4, RoundingMode.HALF_UP);
    }

    private List<String> missingRequiredTripFields(TripEvent event) {
        List<String> missing = new java.util.ArrayList<>();
        if (event.getDistanceKm() == null && (event.getStartMileageKm() == null || event.getEndMileageKm() == null)) {
            missing.add("distanceKm");
        }
        if (event.getFuelLiters() == null) {
            missing.add("fuelLiters");
        }
        if (event.getDurationMinutes() == null) {
            missing.add("durationMinutes");
        }
        return missing;
    }

    public record TripUpdate(
            OffsetDateTime endedAt,
            Integer distanceKm,
            Integer durationMinutes,
            BigDecimal fuelLiters,
            String notes) {
    }
}
