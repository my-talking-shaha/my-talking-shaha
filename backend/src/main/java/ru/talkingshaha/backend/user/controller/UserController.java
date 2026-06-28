package ru.talkingshaha.backend.user.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.talkingshaha.backend.auth.dto.UserResponse;
import ru.talkingshaha.backend.common.error.ApiError;
import ru.talkingshaha.backend.user.model.AppUser;
import ru.talkingshaha.backend.user.service.CurrentUserService;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final CurrentUserService currentUserService;

    public UserController(CurrentUserService currentUserService) {
        this.currentUserService = currentUserService;
    }

    @GetMapping("/me")
    @Operation(summary = "Get the profile of the authenticated user")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Profile of the authenticated user"),
            @ApiResponse(
                    responseCode = "401",
                    description = "Access token is missing or invalid",
                    content = @Content(schema = @Schema(implementation = ApiError.class))),
            @ApiResponse(
                    responseCode = "404",
                    description = "Authenticated user no longer exists",
                    content = @Content(schema = @Schema(implementation = ApiError.class)))
    })
    public UserResponse me() {
        AppUser user = currentUserService.currentUser();
        return new UserResponse(user.getId(), user.getEmail(), user.getDisplayName());
    }
}
