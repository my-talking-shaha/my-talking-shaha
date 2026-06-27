package ru.talkingshaha.backend.chat.repository;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.chat.model.ChatSession;
import ru.talkingshaha.backend.vehicle.model.Vehicle;

public interface ChatSessionRepository extends JpaRepository<ChatSession, UUID> {
    Optional<ChatSession> findByVehicle(Vehicle vehicle);
}