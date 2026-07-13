package ru.talkingshaha.backend.timeline.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.talkingshaha.backend.common.model.BaseEvent;
import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.vehicle.model.Vehicle;

public interface TimelineEventRepository extends JpaRepository<BaseEvent, UUID> {

    List<BaseEvent> findAllByVehicleOrderByEventDateTimeDesc(Vehicle vehicle);

    List<BaseEvent> findAllByVehicleAndTypeOrderByEventDateTimeDesc(Vehicle vehicle, TimelineEventType type);

    Optional<BaseEvent> findByIdAndVehicle(UUID id, Vehicle vehicle);

    @Query("select count(e) from BaseEvent e where e.type = :type and e.vehicle.owner.email <> :email")
    long countByTypeAndVehicleOwnerEmailNot(@Param("type") TimelineEventType type, @Param("email") String email);
}
