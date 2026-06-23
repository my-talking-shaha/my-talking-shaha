package ru.talkingshaha.backend.common.config;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.common.model.BaseEvent;
import ru.talkingshaha.backend.part.model.Part;
import ru.talkingshaha.backend.part.model.PartCategory;
import ru.talkingshaha.backend.part.repository.PartRepository;
import ru.talkingshaha.backend.prediction.dto.PartLifetimeRequest;
import ru.talkingshaha.backend.prediction.service.PartLifetimeService;
import ru.talkingshaha.backend.timeline.model.MaintenanceEvent;
import ru.talkingshaha.backend.timeline.model.RefuelEvent;
import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.timeline.model.TripEvent;
import ru.talkingshaha.backend.timeline.repository.TimelineEventRepository;
import ru.talkingshaha.backend.user.model.AppUser;
import ru.talkingshaha.backend.user.service.CurrentUserService;
import ru.talkingshaha.backend.vehicle.model.FuelType;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.repository.VehicleRepository;

@Component
public class DemoDataSeeder implements ApplicationRunner {

    private final boolean enabled;
    private final CurrentUserService currentUserService;
    private final VehicleRepository vehicles;
    private final PartRepository parts;
    private final TimelineEventRepository events;
    private final PartLifetimeService lifetimeService;

    public DemoDataSeeder(
            @Value("${app.demo-data.enabled:true}") boolean enabled,
            CurrentUserService currentUserService,
            VehicleRepository vehicles,
            PartRepository parts,
            TimelineEventRepository events,
            PartLifetimeService lifetimeService) {
        this.enabled = enabled;
        this.currentUserService = currentUserService;
        this.vehicles = vehicles;
        this.parts = parts;
        this.events = events;
        this.lifetimeService = lifetimeService;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (!enabled) {
            return;
        }

        AppUser demoUser = currentUserService.currentUser();
        if (!vehicles.findAllByOwnerOrderByBrandAscModelAsc(demoUser).isEmpty()) {
            return;
        }

        Vehicle vehicle = new Vehicle();
        vehicle.setOwner(demoUser);
        vehicle.setBrand("Lada");
        vehicle.setModel("2106");
        vehicle.setProductionYear(1998);
        vehicle.setColor("Cherry red");
        vehicle.setMileageKm(124580);
        vehicle.setFuelType(FuelType.HYBRID);
        vehicle.setEngineDescription("1.6 L");
        vehicle.setVin("XTA21060012345678");
        vehicles.save(vehicle);

        parts.saveAll(List.of(
                part(vehicle, "Engine oil", PartCategory.ENGINE_OIL, LocalDate.of(2026, 6, 8),
                        124000, 10000, "Shell Helix Ultra 5W-40", "6200"),
                part(vehicle, "Front brake pads", PartCategory.BRAKE_PADS, LocalDate.of(2026, 5, 22),
                        122900, 10000, "Front Brembo pads", "4200"),
                part(vehicle, "Timing belt", PartCategory.TIMING_BELT, LocalDate.of(2025, 12, 1),
                        95000, 10000, "Timing belt replacement interval is almost exhausted", "9800"),
                part(vehicle, "Cabin filter", PartCategory.AIR_FILTER, LocalDate.of(2026, 6, 1),
                        123500, null, "Cabin filter lifetime is tracked manually", "1400")));

        events.saveAll(List.of(
                refuel(vehicle, at(2026, 6, 15, 14, 30), 124580, "45", "2450", "AI-95", "Gazpromneft Station No. 14"),
                maintenance(vehicle, TimelineEventType.MAINTENANCE, at(2026, 6, 8, 11, 0), "Oil and filter change",
                        "Shell Helix Ultra 5W-40, MANN oil filter", 124000, "8900"),
                trip(vehicle, at(2026, 6, 1, 9, 15), 123180, 123600, "Moscow - Tula - Moscow", 432),
                maintenance(vehicle, TimelineEventType.PART_REPLACEMENT, at(2026, 5, 22, 16, 45),
                        "Brake pad replacement", "Front Brembo pads, caliper cleaning", 122900, "4200"),
                refuel(vehicle, at(2026, 5, 12, 20, 0), 122340, "39", "2100", "AI-95", "Lukoil Station")));
    }

    private Part part(
            Vehicle vehicle,
            String name,
            PartCategory category,
            LocalDate installedAt,
            Integer installedMileageKm,
            Integer expectedLifetimeKm,
            String description,
            String cost) {
        Part part = new Part();
        part.setVehicle(vehicle);
        part.setName(name);
        part.setCategory(category);
        part.setInstalledAt(installedAt);
        part.setInstalledMileageKm(installedMileageKm);
        part.setExpectedLifetimeKm(expectedLifetimeKm);
        part.setDescription(description);
        part.setCost(new BigDecimal(cost));

        var lifetime = lifetimeService.calculate(new PartLifetimeRequest(
                vehicle.getMileageKm(), installedMileageKm, expectedLifetimeKm, category));
        part.setRemainingKm(lifetime.remainingKm());
        part.setRemainingPercent(lifetime.remainingPercent());
        part.setStatus(lifetime.status());
        return part;
    }

    private RefuelEvent refuel(
            Vehicle vehicle,
            OffsetDateTime eventDateTime,
            Integer mileageKm,
            String liters,
            String cost,
            String fuelName,
            String stationName) {
        RefuelEvent event = new RefuelEvent();
        event.setVehicle(vehicle);
        event.setType(TimelineEventType.REFUEL);
        event.setEventDateTime(eventDateTime);
        event.setMileageKm(mileageKm);
        event.setLiters(new BigDecimal(liters));
        event.setCost(new BigDecimal(cost));
        event.setFuelType(FuelType.GASOLINE);
        event.setFuelName(fuelName);
        event.setStationName(stationName);
        return event;
    }

    private TripEvent trip(
            Vehicle vehicle,
            OffsetDateTime eventDateTime,
            Integer startMileageKm,
            Integer endMileageKm,
            String route,
            Integer durationMinutes) {
        TripEvent event = new TripEvent();
        event.setVehicle(vehicle);
        event.setType(TimelineEventType.TRIP);
        event.setEventDateTime(eventDateTime);
        event.setStartMileageKm(startMileageKm);
        event.setEndMileageKm(endMileageKm);
        event.setRoute(route);
        event.setDurationMinutes(durationMinutes);
        return event;
    }

    private MaintenanceEvent maintenance(
            Vehicle vehicle,
            TimelineEventType type,
            OffsetDateTime eventDateTime,
            String name,
            String description,
            Integer mileageKm,
            String cost) {
        MaintenanceEvent event = new MaintenanceEvent();
        event.setVehicle(vehicle);
        event.setType(type);
        event.setEventDateTime(eventDateTime);
        event.setName(name);
        event.setDescription(description);
        event.setMileageKm(mileageKm);
        event.setCost(new BigDecimal(cost));
        return event;
    }

    private OffsetDateTime at(int year, int month, int day, int hour, int minute) {
        return OffsetDateTime.of(year, month, day, hour, minute, 0, 0, ZoneOffset.UTC);
    }
}