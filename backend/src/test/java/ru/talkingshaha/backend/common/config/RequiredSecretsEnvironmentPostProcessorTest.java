package ru.talkingshaha.backend.common.config;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.springframework.mock.env.MockEnvironment;

class RequiredSecretsEnvironmentPostProcessorTest {

    private final RequiredSecretsEnvironmentPostProcessor validator =
            new RequiredSecretsEnvironmentPostProcessor();

    @Test
    void rejectsMissingJwtSecret() {
        MockEnvironment environment = environmentWithProductionSecrets();
        environment.setProperty("app.jwt.secret", "");

        assertThatThrownBy(() -> validator.postProcessEnvironment(environment, null))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("JWT_SECRET is required");
    }

    @Test
    void rejectsShortJwtSecret() {
        MockEnvironment environment = environmentWithProductionSecrets();
        environment.setProperty("app.jwt.secret", "too-short");

        assertThatThrownBy(() -> validator.postProcessEnvironment(environment, null))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("at least 32 bytes");
    }

    @Test
    void rejectsCommittedJwtPlaceholder() {
        MockEnvironment environment = environmentWithProductionSecrets();
        environment.setProperty(
                "app.jwt.secret",
                RequiredSecretsEnvironmentPostProcessor.DEV_JWT_PLACEHOLDER);

        assertThatThrownBy(() -> validator.postProcessEnvironment(environment, null))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("committed development placeholder");
    }

    @Test
    void rejectsMissingDatabaseCredentialsOutsideLocalOrTestProfiles() {
        MockEnvironment environment = new MockEnvironment()
                .withProperty("app.jwt.secret", validJwtSecret());
        environment.setActiveProfiles("docker");

        assertThatThrownBy(() -> validator.postProcessEnvironment(environment, null))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("DB_USERNAME is required");
    }

    @Test
    void rejectsCommittedDatabaseDefaultsOutsideLocalOrTestProfiles() {
        MockEnvironment environment = new MockEnvironment()
                .withProperty("app.jwt.secret", validJwtSecret())
                .withProperty("spring.datasource.username", "shaha_user")
                .withProperty("spring.datasource.password", "shaha_password");
        environment.setActiveProfiles("docker");

        assertThatThrownBy(() -> validator.postProcessEnvironment(environment, null))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("DB_USERNAME");
    }

    @Test
    void allowsMissingDatabaseCredentialsForTestProfile() {
        MockEnvironment environment = new MockEnvironment()
                .withProperty("app.jwt.secret", validJwtSecret());
        environment.setActiveProfiles("test");

        assertThatCode(() -> validator.postProcessEnvironment(environment, null))
                .doesNotThrowAnyException();
    }

    @Test
    void allowsExplicitProductionLikeSecrets() {
        MockEnvironment environment = environmentWithProductionSecrets();

        assertThatCode(() -> validator.postProcessEnvironment(environment, null))
                .doesNotThrowAnyException();
    }

    private MockEnvironment environmentWithProductionSecrets() {
        MockEnvironment environment = new MockEnvironment()
                .withProperty("app.jwt.secret", validJwtSecret())
                .withProperty("spring.datasource.username", "prod_app_user")
                .withProperty("spring.datasource.password", "prod-db-password-32-bytes");
        environment.setActiveProfiles("docker");
        return environment;
    }

    private String validJwtSecret() {
        return "test-jwt-secret-with-more-than-32-bytes";
    }
}
