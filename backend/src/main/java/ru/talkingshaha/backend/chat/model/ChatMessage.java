package ru.talkingshaha.backend.chat.model;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Column;

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
@Table(name = "chat_messages")
public class ChatMessage extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "session_id", nullable = false)
    private ChatSession session;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ChatRole role;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String text;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;
}