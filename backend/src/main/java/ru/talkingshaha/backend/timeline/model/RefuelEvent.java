package ru.talkingshaha.backend.timeline.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

import ru.talkingshaha.backend.common.model.BaseEvent;
import ru.talkingshaha.backend.vehicle.model.FuelType;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "refuel")
public class RefuelEvent extends BaseEvent {

    @Column(nullable = false)
    private Integer mileageKm;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal liters;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal cost;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private FuelType fuelType;

    @Column(nullable = false, length = 32)
    private String fuelName;

    @Column(nullable = false, length = 255)
    private String stationName;
}