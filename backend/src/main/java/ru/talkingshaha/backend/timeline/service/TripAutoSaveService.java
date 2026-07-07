package ru.talkingshaha.backend.timeline.service;

import java.time.Duration;
import java.time.OffsetDateTime;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.timeline.model.TripCompletionStatus;
import ru.talkingshaha.backend.timeline.repository.TripEventRepository;

@Service
public class TripAutoSaveService {

    private final TripEventRepository trips;
    private final Duration timeout;

    public TripAutoSaveService(
            TripEventRepository trips,
            @Value("${app.trips.auto-save-timeout:PT12H}") Duration timeout) {
        this.trips = trips;
        this.timeout = timeout;
    }

    @Scheduled(
            fixedDelayString = "${app.trips.auto-save-fixed-delay-ms:900000}",
            initialDelayString = "${app.trips.auto-save-initial-delay-ms:900000}")
    @Transactional
    public void autoSaveAbandonedTrips() {
        OffsetDateTime now = OffsetDateTime.now();
        autoSaveAbandonedTrips(now.minus(timeout), now);
    }

    @Transactional
    public int autoSaveAbandonedTrips(OffsetDateTime cutoff, OffsetDateTime endedAt) {
        var abandonedTrips = trips.findAllByStatusAndEndedAtIsNullAndEventDateTimeBefore(
                TripCompletionStatus.IN_PROGRESS,
                cutoff);
        abandonedTrips.forEach(trip -> {
            trip.setEndedAt(endedAt);
            trip.setStatus(TripCompletionStatus.PARTIAL);
        });
        return abandonedTrips.size();
    }
}