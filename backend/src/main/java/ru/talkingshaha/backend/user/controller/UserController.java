package ru.talkingshaha.backend.user.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.talkingshaha.backend.auth.dto.UserResponse;
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
    public UserResponse me() {
        AppUser user = currentUserService.currentUser();
        return new UserResponse(user.getId(), user.getEmail(), user.getDisplayName());
    }
}
