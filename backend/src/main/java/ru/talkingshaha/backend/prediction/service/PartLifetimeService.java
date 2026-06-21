package ru.talkingshaha.backend.prediction.service;

import java.util.Map;

import org.springframework.stereotype.Service;
import ru.talkingshaha.backend.part.model.PartCategory;
import ru.talkingshaha.backend.part.model.PartStatus;
import ru.talkingshaha.backend.prediction.dto.PartLifetimeRequest;
import ru.talkingshaha.backend.prediction.dto.PartLifetimeResponse;

@Service
public class PartLifetimeService {

    /**
     * Дефолтные ресурсы по категориям в км.
     * Используются когда пользователь не указал expectedLifetimeKm.
     */
    private static final Map<PartCategory, Integer> DEFAULT_LIFETIMES = Map.of(
            PartCategory.ENGINE_OIL,   10_000,
            PartCategory.OIL_FILTER,   10_000,
            PartCategory.AIR_FILTER,   20_000,
            PartCategory.BRAKE_PADS,   40_000,
            PartCategory.TIMING_BELT,  60_000,
            PartCategory.BATTERY,     100_000
            // OTHER — нет дефолта, слишком широкая категория
    );

    public PartLifetimeResponse calculate(PartLifetimeRequest request) {
        Integer effectiveLifetime = resolveLifetime(request);

        if (effectiveLifetime == null) {
            return new PartLifetimeResponse(null, null, PartStatus.UNKNOWN);
        }
        if (request.currentMileageKm() < request.installedMileageKm()) {
            throw new IllegalArgumentException("Current mileage must not be lower than installed mileage");
        }

        int usedKm = request.currentMileageKm() - request.installedMileageKm();
        int remainingKm = effectiveLifetime - usedKm;
        int remainingPercent = Math.max(0, remainingKm * 100 / effectiveLifetime);

        return new PartLifetimeResponse(remainingKm, remainingPercent, status(remainingKm, remainingPercent));
    }

    /**
     * Возвращает ресурс детали:
     * 1. Если пользователь указал — берём его значение
     * 2. Иначе — берём дефолт по категории
     * 3. Если и категории нет дефолта — null (UNKNOWN)
     */
    private Integer resolveLifetime(PartLifetimeRequest request) {
        if (request.expectedLifetimeKm() != null) {
            return request.expectedLifetimeKm();
        }
        if (request.category() != null) {
            return DEFAULT_LIFETIMES.get(request.category());
        }
        return null;
    }

    private PartStatus status(int remainingKm, int remainingPercent) {
        if (remainingKm <= 0) {
            return PartStatus.CRITICAL;
        }
        if (remainingPercent < 10) {
            return PartStatus.ATTENTION;
        }
        return PartStatus.OK;
    }
}
