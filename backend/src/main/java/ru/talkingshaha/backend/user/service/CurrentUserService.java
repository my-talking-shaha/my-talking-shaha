package ru.talkingshaha.backend.user.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.user.model.AppUser;
import ru.talkingshaha.backend.user.repository.AppUserRepository;

@Service
public class CurrentUserService {

    private static final String DEMO_EMAIL = "demo@talkingshaha.local";

    private final AppUserRepository users;

    public CurrentUserService(AppUserRepository users) {
        this.users = users;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public synchronized AppUser currentUser() {
        return findDemoUser().orElseGet(this::createDemoUser);
    }

    private java.util.Optional<AppUser> findDemoUser() {
        return users.findByEmail(DEMO_EMAIL);
    }

    private AppUser createDemoUser() {
        AppUser user = new AppUser();
        user.setEmail(DEMO_EMAIL);
        user.setPasswordHash("auth-is-not-enabled-yet");
        user.setDisplayName("Demo User");
        return users.save(user);
    }
}