package ru.talkingshaha.backend.chat.controller;

import java.util.UUID;

import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import ru.talkingshaha.backend.chat.dto.ChatMessagesResponse;
import ru.talkingshaha.backend.chat.dto.ChatStateResponse;
import ru.talkingshaha.backend.chat.dto.SendMessageRequest;
import ru.talkingshaha.backend.chat.dto.SendMessageResponse;
import ru.talkingshaha.backend.chat.service.ChatService;
import ru.talkingshaha.backend.common.error.ApiError;

@RestController
@RequestMapping("/api/v1/vehicles/{vehicleId}/chat")
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
                description = "Vehicle not found",
                content = @Content(schema = @Schema(implementation = ApiError.class)))
})
public class ChatController {

    private final ChatService chat;

    public ChatController(ChatService chat) {
        this.chat = chat;
    }

    @GetMapping
    public ChatStateResponse state(@PathVariable UUID vehicleId) {
        return chat.state(vehicleId);
    }

    @GetMapping("/messages")
    public ChatMessagesResponse messages(@PathVariable UUID vehicleId) {
        return chat.messages(vehicleId);
    }

    @PostMapping("/messages")
    @ResponseStatus(HttpStatus.CREATED)
    public SendMessageResponse send(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody SendMessageRequest request) {
        return chat.send(vehicleId, request);
    }
}