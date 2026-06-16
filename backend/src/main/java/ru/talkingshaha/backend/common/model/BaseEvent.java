package ru.talkingshaha.backend.common.model;

import jakarta.persistence.Column;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MappedSuperclass;

import java.time.OffsetDateTime;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.vehicle.model.Vehicle;

@Getter
@Setter
@MappedSuperclass
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public abstract class BaseEvent extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private TimelineEventType type;

    @Column(name = "event_date_time", nullable = false)
    private OffsetDateTime eventDateTime;

}