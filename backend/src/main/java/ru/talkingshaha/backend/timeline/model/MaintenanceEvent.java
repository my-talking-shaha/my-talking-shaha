package ru.talkingshaha.backend.timeline.model;


import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "maintenance")
public class Maintenance extends BaseEvent {

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "mileage_km", nullable = false)
    private Integer mileageKm;

    @Column(length = 3)
    private String currency;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal cost;
}