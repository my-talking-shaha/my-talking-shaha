package ru.talkingshaha.backend.part.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.part.model.Part;
import ru.talkingshaha.backend.vehicle.model.Vehicle;

public interface PartRepository extends JpaRepository<Part, UUID> {
    List<Part> findAllByVehicleOrderByInstalledAtDescNameAsc(Vehicle vehicle);

    Optional<Part> findByIdAndVehicle(UUID id, Vehicle vehicle);
}