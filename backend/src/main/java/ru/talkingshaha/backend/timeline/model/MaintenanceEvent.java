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
@Table(name = "maintenance")
public class MaintenanceEvent extends BaseEvent {

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "mileage_km", nullable = false)
    private Integer mileageKm;

    @Column(length = 3)
    private String currency;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal cost;
}