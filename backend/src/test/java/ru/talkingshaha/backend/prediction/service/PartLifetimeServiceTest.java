package ru.talkingshaha.backend.prediction.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import ru.talkingshaha.backend.part.model.PartCategory;
import ru.talkingshaha.backend.part.model.PartStatus;
import ru.talkingshaha.backend.prediction.dto.PartLifetimeRequest;

class PartLifetimeServiceTest {

    private final PartLifetimeService service = new PartLifetimeService();

    // --- Существующие тесты (пользователь задал expectedLifetimeKm) ---

    @Test
    void returnsOkWhenPartHasEnoughLifetime() {
        var result = service.calculate(new PartLifetimeRequest(10000, 8000, 8000, null));
        assertThat(result.remainingKm()).isEqualTo(6000);
        assertThat(result.remainingPercent()).isEqualTo(75);
        assertThat(result.status()).isEqualTo(PartStatus.OK);
    }

    @Test
    void returnsAttentionStatusWhenLessThanTenPercentRemains() {
        var result = service.calculate(new PartLifetimeRequest(15500, 8000, 8000, null));
        assertThat(result.remainingKm()).isEqualTo(500);
        assertThat(result.remainingPercent()).isEqualTo(6);
        assertThat(result.status()).isEqualTo(PartStatus.ATTENTION);
    }

    @Test
    void returnsCriticalStatusWhenLifetimeIsOver() {
        var result = service.calculate(new PartLifetimeRequest(16500, 8000, 8000, null));
        assertThat(result.remainingKm()).isEqualTo(-500);
        assertThat(result.remainingPercent()).isZero();
        assertThat(result.status()).isEqualTo(PartStatus.CRITICAL);
    }

    @Test
    void rejectsMileageLowerThanInstalledMileage() {
        assertThatThrownBy(() -> service.calculate(new PartLifetimeRequest(7000, 8000, 8000, null)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Current mileage must not be lower than installed mileage");
    }

    // --- Rule-based тесты (expectedLifetimeKm не задан, используем дефолт по категории) ---

    @Test
    void usesDefaultLifetimeForEngineOilWhenExpectedNotSet() {
        // ENGINE_OIL дефолт = 10_000 км, установлена при 50_000, сейчас 55_000
        // usedKm = 5_000, remaining = 5_000, percent = 50%
        var result = service.calculate(new PartLifetimeRequest(55_000, 50_000, null, PartCategory.ENGINE_OIL));
        assertThat(result.remainingKm()).isEqualTo(5_000);
        assertThat(result.remainingPercent()).isEqualTo(50);
        assertThat(result.status()).isEqualTo(PartStatus.OK);
    }

    @Test
    void usesDefaultLifetimeForBrakePadsWhenExpectedNotSet() {
        // BRAKE_PADS дефолт = 40_000 км, установлена при 0, сейчас 39_000
        // usedKm = 39_000, remaining = 1_000, percent = 2% → ATTENTION
        var result = service.calculate(new PartLifetimeRequest(39_000, 0, null, PartCategory.BRAKE_PADS));
        assertThat(result.remainingKm()).isEqualTo(1_000);
        assertThat(result.remainingPercent()).isEqualTo(2);
        assertThat(result.status()).isEqualTo(PartStatus.ATTENTION);
    }

    @Test
    void userSpecifiedLifetimeOverridesDefault() {
        // Пользователь задал 5_000 вместо дефолтных 10_000 для ENGINE_OIL
        var result = service.calculate(new PartLifetimeRequest(54_000, 50_000, 5_000, PartCategory.ENGINE_OIL));
        assertThat(result.remainingKm()).isEqualTo(1_000);
        assertThat(result.remainingPercent()).isEqualTo(20);
        assertThat(result.status()).isEqualTo(PartStatus.OK);
    }

    @Test
    void returnsUnknownWhenNeitherLifetimeNorCategoryDefaultExists() {
        // OTHER не имеет дефолта, expectedLifetimeKm не задан
        var result = service.calculate(new PartLifetimeRequest(10_000, 5_000, null, PartCategory.OTHER));
        assertThat(result.remainingKm()).isNull();
        assertThat(result.remainingPercent()).isNull();
        assertThat(result.status()).isEqualTo(PartStatus.UNKNOWN);
    }

    @Test
    void returnsUnknownWhenNoCategoryAndNoExpectedLifetime() {
        var result = service.calculate(new PartLifetimeRequest(10_000, 5_000, null, null));
        assertThat(result.status()).isEqualTo(PartStatus.UNKNOWN);
    }
}
