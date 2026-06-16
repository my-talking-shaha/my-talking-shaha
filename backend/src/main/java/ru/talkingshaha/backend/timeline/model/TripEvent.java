package ru.talkingshaha.backend.timeline.model;


import jakarta.persistence.*;
import lombok.*;

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
    private java.math.BigDecimal cost;
}