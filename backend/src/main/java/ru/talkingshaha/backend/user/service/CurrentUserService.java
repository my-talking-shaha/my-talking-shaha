package ru.talkingshaha.backend.user.service;

import java.util.UUID;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import ru.talkingshaha.backend.common.error.ResourceNotFoundException;
import ru.talkingshaha.backend.user.model.AppUser;
import ru.talkingshaha.backend.user.repository.AppUserRepository;

@Service
public class CurrentUserService {

    private final AppUserRepository users;

    public CurrentUserService(AppUserRepository users) {
        this.users = users;
    }

    public AppUser currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof UUID userId)) {
            throw new AuthenticationCredentialsNotFoundException("Authentication is required");
        }
        return users.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
