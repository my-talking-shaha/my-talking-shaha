package ru.talkingshaha.backend.chat.controller;

import java.util.UUID;

import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import ru.talkingshaha.backend.chat.dto.TripDataCollectionRequest;
import ru.talkingshaha.backend.chat.dto.TripEndRequest;
import ru.talkingshaha.backend.chat.dto.TripLifecycleResponse;
import ru.talkingshaha.backend.chat.dto.TripStartRequest;
import ru.talkingshaha.backend.chat.service.TripChatService;
import ru.talkingshaha.backend.common.error.ApiError;

@RestController
@RequestMapping("/api/v1/vehicles/{vehicleId}/chat/trips")
@ApiResponses({
        @ApiResponse(
                responseCode = "400",
                description = "Validation error",
                content = @Content(schema = @Schema(implementation = ApiError.class))),
        @ApiResponse(
                responseCode = "403",
                description = "Vehicle belongs to another user",
                content = @Content(schema = @Schema(implementation = ApiError.class))),
        @ApiResponse(
                responseCode = "404",
                description = "Vehicle or trip not found",
                content = @Content(schema = @Schema(implementation = ApiError.class)))
})
public class TripChatController {

    private final TripChatService trips;

    public TripChatController(TripChatService trips) {
        this.trips = trips;
    }

    @PostMapping("/start")
    @ResponseStatus(HttpStatus.CREATED)
    public TripLifecycleResponse start(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody TripStartRequest request) {
        return trips.start(vehicleId, request);
    }

    @PostMapping("/{tripId}/end")
    public TripLifecycleResponse end(
            @PathVariable UUID vehicleId,
            @PathVariable UUID tripId,
            @Valid @RequestBody TripEndRequest request) {
        return trips.end(vehicleId, tripId, request);
    }

    @PostMapping("/{tripId}/data")
    public TripLifecycleResponse collectData(
            @PathVariable UUID vehicleId,
            @PathVariable UUID tripId,
            @Valid @RequestBody TripDataCollectionRequest request) {
        return trips.collectData(vehicleId, tripId, request);
    }
}