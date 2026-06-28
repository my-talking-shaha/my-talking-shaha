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
@Table(name = "chat_messages")
public class ChatMessage extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "session_id", nullable = false)
    private ChatSession session;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ChatMessageRole role;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String text;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "action_type")
    private String actionType;

    @Column(name = "action_form")
    private String actionForm;

    @Column(name = "action_screen")
    private String actionScreen;

    @Column(name = "action_prefill", columnDefinition = "TEXT")
    private String actionPrefill;
}
