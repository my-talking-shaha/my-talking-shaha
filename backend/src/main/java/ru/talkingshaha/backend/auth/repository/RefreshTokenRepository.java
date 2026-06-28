package ru.talkingshaha.backend.auth.repository;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.auth.model.RefreshToken;
import ru.talkingshaha.backend.user.model.AppUser;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findByToken(String token);

    void deleteByToken(String token);

    void deleteByUser(AppUser user);
}