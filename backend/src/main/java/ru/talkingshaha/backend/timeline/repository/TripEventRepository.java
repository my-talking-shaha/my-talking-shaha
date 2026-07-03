package ru.talkingshaha.backend.timeline.repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.timeline.model.TripCompletionStatus;
import ru.talkingshaha.backend.timeline.model.TripEvent;
import ru.talkingshaha.backend.vehicle.model.Vehicle;

public interface TripEventRepository extends JpaRepository<TripEvent, UUID> {
    Optional<TripEvent> findByIdAndVehicle(UUID id, Vehicle vehicle);

    Optional<TripEvent> findTopByChatSessionAndStatusOrderByEventDateTimeDesc(
            ru.talkingshaha.backend.chat.model.ChatSession chatSession,
            TripCompletionStatus status);

    List<TripEvent> findAllByStatusAndEndedAtIsNullAndEventDateTimeBefore(
            TripCompletionStatus status,
            OffsetDateTime cutoff);
}