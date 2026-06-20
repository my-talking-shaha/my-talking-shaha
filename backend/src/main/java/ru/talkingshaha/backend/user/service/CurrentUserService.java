package ru.talkingshaha.backend.user.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.user.model.AppUser;
import ru.talkingshaha.backend.user.repository.AppUserRepository;

@Service
public class CurrentUserService {

    private static final String DEMO_USERNAME = "demo-user";

    private final AppUserRepository users;

    public CurrentUserService(AppUserRepository users) {
        this.users = users;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public AppUser currentUser() {
        return users.findByUsername(DEMO_USERNAME).orElseGet(this::createDemoUser);
    }

    private AppUser createDemoUser() {
        AppUser user = new AppUser();
        user.setEmail("demo@talkingshaha.local");
        user.setUsername(DEMO_USERNAME);
        user.setPasswordHash("auth-is-not-enabled-yet");
        user.setDisplayName("Demo User");
        return users.save(user);
    }
}