package ru.talkingshaha.backend.timeline.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.timeline.model.TripEvent;
import ru.talkingshaha.backend.vehicle.model.Vehicle;

public interface TripEventRepository extends JpaRepository<TripEvent, UUID> {
    Optional<TripEvent> findByIdAndVehicle(UUID id, Vehicle vehicle);
}