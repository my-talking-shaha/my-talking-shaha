package ru.talkingshaha.backend.timeline.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.timeline.model.TripEvent;

public interface TripEventRepository extends JpaRepository<TripEvent, UUID> {
}
