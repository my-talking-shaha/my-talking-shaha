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

@RestController
@RequestMapping("/api/v1/vehicles/{vehicleId}/events")
public class TimelineEventController {

    private final TimelineEventService service;

    public TimelineEventController(TimelineEventService service) {
        this.service = service;
    }

    @GetMapping
    public TimelineEventListResponse getEvents(
            @PathVariable UUID vehicleId,
            @RequestParam(required = false) TimelineEventType type) {
        return service.getEvents(vehicleId, type);
    }

    @PostMapping("/refuel")
    @ResponseStatus(HttpStatus.CREATED)
    public TimelineEventResponse createRefuelEvent(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody CreateRefuelEventRequest request) {
        return service.createRefuelEvent(vehicleId, request);
    }

    @PostMapping("/trip")
    @ResponseStatus(HttpStatus.CREATED)
    public TimelineEventResponse createTripEvent(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody CreateTripEventRequest request) {
        return service.createTripEvent(vehicleId, request);
    }

    @PostMapping("/maintenance")
    @ResponseStatus(HttpStatus.CREATED)
    public TimelineEventResponse createMaintenanceEvent(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody CreateMaintenanceEventRequest request) {
        return service.createMaintenanceEvent(vehicleId, request);
    }
}
