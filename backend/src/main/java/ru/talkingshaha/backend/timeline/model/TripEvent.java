package ru.talkingshaha.backend.timeline.model;


package ru.talkingshaha.backend.timeline.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import java.math.BigDecimal;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import ru.talkingshaha.backend.common.model.BaseEvent;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "trips")
public class Trip extends BaseEvent {

    @Column(name = "start_mileage_km", nullable = false)
    private Integer startMileageKm;

    @Column(name = "end_mileage_km", nullable = false)
    private Integer endMileageKm;

    @Column(nullable = false)
    private String route;

    @Column(name = "duration_minutes", nullable = false)
    private Integer durationMinutes;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal cost;
}