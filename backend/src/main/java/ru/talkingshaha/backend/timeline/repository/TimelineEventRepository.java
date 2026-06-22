package ru.talkingshaha.backend.timeline.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.common.model.BaseEvent;
import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.vehicle.model.Vehicle;

public interface TimelineEventRepository extends JpaRepository<BaseEvent, UUID> {

    List<BaseEvent> findAllByVehicleOrderByEventDateTimeDesc(Vehicle vehicle);

    List<BaseEvent> findAllByVehicleAndTypeOrderByEventDateTimeDesc(Vehicle vehicle, TimelineEventType type);
}
