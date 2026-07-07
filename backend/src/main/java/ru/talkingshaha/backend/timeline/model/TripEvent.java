package ru.talkingshaha.backend.timeline.model;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import ru.talkingshaha.backend.chat.model.ChatSession;
import ru.talkingshaha.backend.common.model.BaseEvent;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "trips")
public class TripEvent extends BaseEvent {

    @Column(nullable = false, length = 255)
    private String title;

    @Column(name = "start_mileage_km")
    private Integer startMileageKm;

    @Column(name = "end_mileage_km")
    private Integer endMileageKm;

    @Column(name = "distance_km")
    private Integer distanceKm;

    @Column
    private String route;

    @Column(name = "duration_minutes")
    private Integer durationMinutes;

    @Column(name = "ended_at")
    private OffsetDateTime endedAt;

    @Column(name = "fuel_liters")
    private BigDecimal fuelLiters;

    @Column
    private String notes;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TripCompletionStatus status = TripCompletionStatus.COMPLETE;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chat_session_id")
    private ChatSession chatSession;
}