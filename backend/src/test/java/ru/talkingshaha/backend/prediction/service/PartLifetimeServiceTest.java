package ru.talkingshaha.backend.prediction.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import ru.talkingshaha.backend.part.model.PartStatus;
import ru.talkingshaha.backend.prediction.dto.PartLifetimeRequest;

class PartLifetimeServiceTest {

    private final PartLifetimeService service = new PartLifetimeService();

    @Test
    void returnsOkWhenPartHasEnoughLifetime() {
        var result = service.calculate(new PartLifetimeRequest(10000, 8000, 8000));
        assertThat(result.remainingKm()).isEqualTo(6000);
        assertThat(result.remainingPercent()).isEqualTo(75);
        assertThat(result.status()).isEqualTo(PartStatus.OK);
    }

    @Test
    void returnsAttentionStatusWhenLessThanTenPercentRemains() {
        var result = service.calculate(new PartLifetimeRequest(15500, 8000, 8000));
        assertThat(result.remainingKm()).isEqualTo(500);
        assertThat(result.remainingPercent()).isEqualTo(6);
        assertThat(result.status()).isEqualTo(PartStatus.ATTENTION);
    }

    @Test
    void returnsCriticalStatusWhenLifetimeIsOver() {
        var result = service.calculate(new PartLifetimeRequest(16500, 8000, 8000));
        assertThat(result.remainingKm()).isEqualTo(-500);
        assertThat(result.remainingPercent()).isZero();
        assertThat(result.status()).isEqualTo(PartStatus.CRITICAL);
    }

    @Test
    void rejectsMileageLowerThanInstalledMileage() {
        assertThatThrownBy(() -> service.calculate(new PartLifetimeRequest(7000, 8000, 8000)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Current mileage must not be lower than installed mileage");
    }
}