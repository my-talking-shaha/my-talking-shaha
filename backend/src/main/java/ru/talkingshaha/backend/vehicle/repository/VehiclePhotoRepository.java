package ru.talkingshaha.backend.vehicle.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.model.VehiclePhoto;

public interface VehiclePhotoRepository extends JpaRepository<VehiclePhoto, UUID> {
    List<VehiclePhoto> findAllByVehicleOrderByCreatedAtAscIdAsc(Vehicle vehicle);

    Optional<VehiclePhoto> findFirstByVehicleOrderByCreatedAtAscIdAsc(Vehicle vehicle);
}
