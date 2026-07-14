package ru.talkingshaha.backend.timeline.model;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

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

    @Column(nullable = false, length = 255)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "mileage_km", nullable = false)
    private Integer mileageKm;

    @Column(precision = 10, scale = 2)
    private BigDecimal cost;

    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<EventPhoto> photos = new ArrayList<>();
}