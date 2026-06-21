package ru.talkingshaha.backend.timeline.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.timeline.model.RefuelEvent;

public interface RefuelEventRepository extends JpaRepository<RefuelEvent, UUID> {
}
