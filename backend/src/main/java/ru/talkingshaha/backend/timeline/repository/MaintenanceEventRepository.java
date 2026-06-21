package ru.talkingshaha.backend.timeline.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.timeline.model.MaintenanceEvent;

public interface MaintenanceEventRepository extends JpaRepository<MaintenanceEvent, UUID> {
}
