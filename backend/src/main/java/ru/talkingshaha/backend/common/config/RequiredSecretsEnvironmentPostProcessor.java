package ru.talkingshaha.backend.common.config;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Locale;
import java.util.Set;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.util.StringUtils;

public class RequiredSecretsEnvironmentPostProcessor implements EnvironmentPostProcessor, Ordered {

    static final String DEV_JWT_PLACEHOLDER = "dev-secret-change-me-please-32+bytes-minimum-0123456789";
    private static final String EXAMPLE_JWT_PLACEHOLDER = "replace-me-with-at-least-32-random-bytes";
    private static final int MIN_JWT_SECRET_BYTES = 32;
    private static final int MIN_DB_PASSWORD_BYTES = 12;
    private static final Set<String> LOCAL_OR_TEST_PROFILES = Set.of("local", "test");
    private static final Set<String> UNSAFE_DB_USERNAMES = Set.of("shaha_user", "replace-me");
    private static final Set<String> UNSAFE_DB_PASSWORDS = Set.of("shaha_password", "replace-me");

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        validateJwtSecret(environment.getProperty("app.jwt.secret"));

        if (!isLocalOrTest(environment)) {
            validateDatabaseCredentials(
                    environment.getProperty("spring.datasource.username"),
                    environment.getProperty("spring.datasource.password"));
        }
    }

    @Override
    public int getOrder() {
        return Ordered.LOWEST_PRECEDENCE;
    }

    static void validateJwtSecret(String secret) {
        if (!StringUtils.hasText(secret)) {
            throw new IllegalStateException("JWT_SECRET is required and must be at least 32 bytes.");
        }

        int secretBytes = secret.getBytes(StandardCharsets.UTF_8).length;
        if (secretBytes < MIN_JWT_SECRET_BYTES) {
            throw new IllegalStateException("JWT_SECRET must be at least 32 bytes.");
        }

        if (DEV_JWT_PLACEHOLDER.equals(secret) || EXAMPLE_JWT_PLACEHOLDER.equals(secret)) {
            throw new IllegalStateException("JWT_SECRET must not use a committed development placeholder.");
        }

        if (looksLikePlaceholder(secret)) {
            throw new IllegalStateException("JWT_SECRET must be a real secret, not a placeholder value.");
        }
    }

    static void validateDatabaseCredentials(String username, String password) {
        if (!StringUtils.hasText(username)) {
            throw new IllegalStateException("DB_USERNAME is required outside local/test profiles.");
        }

        if (!StringUtils.hasText(password)) {
            throw new IllegalStateException("DB_PASSWORD is required outside local/test profiles.");
        }

        if (isUnsafeUsername(username)) {
            throw new IllegalStateException("DB_USERNAME must not use a committed development placeholder.");
        }

        if (isUnsafePassword(password)) {
            throw new IllegalStateException("DB_PASSWORD must not use a committed development placeholder.");
        }

        int passwordBytes = password.getBytes(StandardCharsets.UTF_8).length;
        if (passwordBytes < MIN_DB_PASSWORD_BYTES) {
            throw new IllegalStateException("DB_PASSWORD must be at least 12 bytes outside local/test profiles.");
        }
    }

    private static boolean isLocalOrTest(ConfigurableEnvironment environment) {
        return Arrays.stream(environment.getActiveProfiles())
                .map(profile -> profile.toLowerCase(Locale.ROOT))
                .anyMatch(LOCAL_OR_TEST_PROFILES::contains);
    }

    private static boolean isUnsafeUsername(String username) {
        return UNSAFE_DB_USERNAMES.contains(username.toLowerCase(Locale.ROOT)) || looksLikePlaceholder(username);
    }

    private static boolean isUnsafePassword(String password) {
        return UNSAFE_DB_PASSWORDS.contains(password.toLowerCase(Locale.ROOT)) || looksLikePlaceholder(password);
    }

    private static boolean looksLikePlaceholder(String value) {
        String normalized = value.toLowerCase(Locale.ROOT);
        return normalized.contains("change-me")
                || normalized.contains("changeme")
                || normalized.contains("replace-me")
                || normalized.contains("your_")
                || normalized.contains("your-");
    }
}
