package ru.talkingshaha.backend.chat.model;

import jakarta.persistence.*;

import java.time.OffsetDateTime;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import ru.talkingshaha.backend.common.model.BaseEntity;
import ru.talkingshaha.backend.vehicle.model.Vehicle;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "chat_sessions")
public class ChatSession extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;
}