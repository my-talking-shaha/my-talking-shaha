package ru.talkingshaha.backend.vehicle.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.user.model.AppUser;
import ru.talkingshaha.backend.vehicle.model.Vehicle;

public interface VehicleRepository extends JpaRepository<Vehicle, UUID> {
    List<Vehicle> findAllByOwnerOrderByBrandAscModelAsc(AppUser owner);

    Optional<Vehicle> findByIdAndOwner(UUID id, AppUser owner);
}