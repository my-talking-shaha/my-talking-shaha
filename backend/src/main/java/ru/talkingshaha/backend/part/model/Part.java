package ru.talkingshaha.backend.part.model;

import java.math.BigDecimal;
import java.time.LocalDate;

import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import ru.talkingshaha.backend.common.model.BaseEntity;
import ru.talkingshaha.backend.vehicle.model.Vehicle;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "parts")
public class Part extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;

    @Column(nullable = false, length = 255)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private PartCategory category;

    @Column(name = "installed_at", nullable = false)
    private LocalDate installedAt;

    @Column(name = "installed_mileage_km", nullable = false)
    private Integer installedMileageKm;

    @Column(name = "expected_lifetime_km")
    private Integer expectedLifetimeKm;

    @Column(name = "remaining_km")
    private Integer remainingKm;

    @Column(name = "remaining_percent")
    private Integer remainingPercent;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PartStatus status;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(precision = 10, scale = 2)
    private BigDecimal cost;

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "part_photos", joinColumns = @JoinColumn(name = "part_id"))
    @Column(name = "photo_url", nullable = false, length = 500)
    private List<String> photoUrls = new ArrayList<>();
}