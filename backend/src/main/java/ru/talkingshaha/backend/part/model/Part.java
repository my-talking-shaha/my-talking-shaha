package ru.talkingshaha.backend.part.model;

import jakarta.persistence.*;

import java.time.LocalDate;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import ru.talkingshaha.backend.common.model.BaseEntity;
import ru.talkingshaha.backend.timeline.model.Maintenance;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "parts")
public class Part extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "maintenance_id", nullable = false)
    private Maintenance maintenance;

    @Column(nullable = false, length = 255)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private PartCategory category;

    @Column(length = 3)
    private String currency;

    @Column(name = "installed_at", nullable = false)
    private LocalDate installedAt;

    @Column(name = "installed_mileage_km", nullable = false)
    private Integer installedMileageKm;

    @Column(name = "expected_lifetime_km", nullable = false)
    private Integer expectedLifetimeKm;

    @Column(name = "remaining_km", nullable = false)
    private Integer remainingKm;

    @Column(name = "remaining_percent", nullable = false)
    private Integer remainingPercent;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PartStatus status;
}