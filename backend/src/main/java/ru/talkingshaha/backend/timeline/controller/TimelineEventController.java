package ru.talkingshaha.backend.timeline.controller;

import java.util.UUID;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import ru.talkingshaha.backend.timeline.dto.CreateMaintenanceEventRequest;
import ru.talkingshaha.backend.timeline.dto.CreateRefuelEventRequest;
import ru.talkingshaha.backend.timeline.dto.CreateTripEventRequest;
import ru.talkingshaha.backend.timeline.dto.TimelineEventListResponse;
import ru.talkingshaha.backend.timeline.dto.TimelineEventResponse;
import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.timeline.service.TimelineEventService;

/**
 * REST API for a vehicle's timeline (service history) events.
 *
 * <p>Events are typed: refuels, trips, and maintenance. Creating an event may advance the
 * vehicle's stored mileage and recalculate the lifetime of its parts.
 */
@RestController
@RequestMapping("/api/v1/vehicles/{vehicleId}/events")
public class TimelineEventController {

    private final TimelineEventService service;

    public TimelineEventController(TimelineEventService service) {
        this.service = service;
    }

    /**
     * Lists the timeline events of a vehicle, most recent first.
     *
     * @param vehicleId the vehicle identifier
     * @param type      optional filter by event type; when null, all types are returned
     * @return the matching timeline events
     */
    @GetMapping
    public TimelineEventListResponse getEvents(
            @PathVariable UUID vehicleId,
            @RequestParam(required = false) TimelineEventType type) {
        return service.getEvents(vehicleId, type);
    }

    /**
     * Records a refuel event for a vehicle.
     *
     * @param vehicleId the vehicle identifier
     * @param request   the refuel data
     * @return the created timeline event
     */
    @PostMapping("/refuel")
    @ResponseStatus(HttpStatus.CREATED)
    public TimelineEventResponse createRefuelEvent(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody CreateRefuelEventRequest request) {
        return service.createRefuelEvent(vehicleId, request);
    }

    /**
     * Records a trip event for a vehicle.
     *
     * @param vehicleId the vehicle identifier
     * @param request   the trip data
     * @return the created timeline event
     */
    @PostMapping("/trip")
    @ResponseStatus(HttpStatus.CREATED)
    public TimelineEventResponse createTripEvent(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody CreateTripEventRequest request) {
        return service.createTripEvent(vehicleId, request);
    }

    /**
     * Records a maintenance event for a vehicle.
     *
     * @param vehicleId the vehicle identifier
     * @param request   the maintenance data
     * @return the created timeline event
     */
    @PostMapping("/maintenance")
    @ResponseStatus(HttpStatus.CREATED)
    public TimelineEventResponse createMaintenanceEvent(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody CreateMaintenanceEventRequest request) {
        return service.createMaintenanceEvent(vehicleId, request);
    }
}
