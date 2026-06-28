package ru.talkingshaha.backend.user.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.user.model.AppUser;

import java.util.UUID;

public interface AppUserRepository extends JpaRepository<AppUser, UUID> {
    Optional<AppUser> findByEmail(String email);
}