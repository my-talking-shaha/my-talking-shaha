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

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "event_photos", joinColumns = @JoinColumn(name = "event_id"))
    @Column(name = "photo_url", nullable = false, length = 500)
    private List<String> photoUrls = new ArrayList<>();
}