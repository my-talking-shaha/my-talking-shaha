package ru.talkingshaha.backend.prediction.service;

import org.springframework.stereotype.Service;
import ru.talkingshaha.backend.part.model.PartStatus;
import ru.talkingshaha.backend.prediction.dto.PartLifetimeRequest;
import ru.talkingshaha.backend.prediction.dto.PartLifetimeResponse;

@Service
public class PartLifetimeService {

    public PartLifetimeResponse calculate(PartLifetimeRequest request) {
        if (request.expectedLifetimeKm() == null) {
            return new PartLifetimeResponse(null, null, PartStatus.UNKNOWN);
        }
        if (request.currentMileageKm() < request.installedMileageKm()) {
            throw new IllegalArgumentException("Current mileage must not be lower than installed mileage");
        }
        int usedKm = request.currentMileageKm() - request.installedMileageKm();
        int remainingKm = request.expectedLifetimeKm() - usedKm;
        int remainingPercent = Math.max(0, remainingKm * 100 / request.expectedLifetimeKm());
        return new PartLifetimeResponse(remainingKm, remainingPercent, status(remainingKm, remainingPercent));
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