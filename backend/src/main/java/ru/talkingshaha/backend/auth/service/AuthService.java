package ru.talkingshaha.backend.auth.service;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Base64;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.auth.dto.*;
import ru.talkingshaha.backend.auth.model.RefreshToken;
import ru.talkingshaha.backend.auth.repository.RefreshTokenRepository;
import ru.talkingshaha.backend.auth.security.JwtService;
import ru.talkingshaha.backend.common.error.EmailAlreadyExistsException;
import ru.talkingshaha.backend.common.error.InvalidCredentialsException;
import ru.talkingshaha.backend.user.model.AppUser;
import ru.talkingshaha.backend.user.repository.AppUserRepository;

@Service
public class AuthService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final AppUserRepository users;
    private final RefreshTokenRepository refreshTokens;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final Duration refreshTtl;

    public AuthService(
            AppUserRepository users,
            RefreshTokenRepository refreshTokens,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            @Value("${app.jwt.refresh-ttl}") Duration refreshTtl) {
        this.users = users;
        this.refreshTokens = refreshTokens;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.refreshTtl = refreshTtl;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (users.findByEmail(request.email()).isPresent()) {
            throw new EmailAlreadyExistsException("Email already registered");
        }
        AppUser user = new AppUser();
        user.setEmail(request.email());
        user.setDisplayName(request.displayName());
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        users.save(user);
        return issueTokens(user);
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        AppUser user = users.findByEmail(request.email())
                .orElseThrow(() -> new InvalidCredentialsException("Invalid email or password"));
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new InvalidCredentialsException("Invalid email or password");
        }
        return issueTokens(user);
    }

    private AuthResponse issueTokens(AppUser user) {
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = createRefreshToken(user);
        return new AuthResponse(toUserResponse(user), accessToken, refreshToken);
    }

    private String createRefreshToken(AppUser user) {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String value = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);

        RefreshToken token = new RefreshToken();
        token.setUser(user);
        token.setToken(value);
        token.setExpiresAt(OffsetDateTime.now(ZoneOffset.UTC).plus(refreshTtl));
        refreshTokens.save(token);
        return value;
    }

    private UserResponse toUserResponse(AppUser user) {
        return new UserResponse(user.getId(), user.getEmail(), user.getDisplayName());
    }

    @Transactional
    public TokenResponse refresh(String refreshTokenValue) {
        RefreshToken stored = refreshTokens.findByToken(refreshTokenValue)
                .orElseThrow(() -> new InvalidCredentialsException("Invalid refresh token"));

        if (stored.getExpiresAt().isBefore(OffsetDateTime.now(ZoneOffset.UTC))) {
            refreshTokens.delete(stored);
            throw new InvalidCredentialsException("Refresh token expired");
        }

        AppUser user = stored.getUser();
        refreshTokens.delete(stored);
        String accessToken = jwtService.generateAccessToken(user);
        String newRefreshToken = createRefreshToken(user);
        return new TokenResponse(accessToken, newRefreshToken);
    }

    @Transactional
    public void logout(String refreshTokenValue) {
        refreshTokens.deleteByToken(refreshTokenValue);
    }
}