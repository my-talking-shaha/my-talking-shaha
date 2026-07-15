package ru.talkingshaha.backend.part.service;

import java.util.List;
import java.util.LinkedHashSet;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import ru.talkingshaha.backend.common.error.ResourceNotFoundException;
import ru.talkingshaha.backend.common.metrics.BusinessMetrics;
import ru.talkingshaha.backend.part.dto.CreatePartRequest;
import ru.talkingshaha.backend.part.dto.PartListResponse;
import ru.talkingshaha.backend.part.dto.PartResponse;
import ru.talkingshaha.backend.part.dto.UpdatePartRequest;
import ru.talkingshaha.backend.part.model.Part;
import ru.talkingshaha.backend.part.model.PartCategory;
import ru.talkingshaha.backend.part.repository.PartRepository;
import ru.talkingshaha.backend.prediction.dto.PartLifetimeRequest;
import ru.talkingshaha.backend.prediction.service.PartLifetimeService;
import ru.talkingshaha.backend.vehicle.model.Vehicle;
import ru.talkingshaha.backend.vehicle.service.VehicleService;

@Service
public class PartService {

    private final PartRepository parts;
    private final VehicleService vehicles;
    private final PartLifetimeService lifetimeService;
    private final BusinessMetrics metrics;

    public PartService(
            PartRepository parts,
            VehicleService vehicles,
            PartLifetimeService lifetimeService,
            BusinessMetrics metrics) {
        this.parts = parts;
        this.vehicles = vehicles;
        this.lifetimeService = lifetimeService;
        this.metrics = metrics;
    }

    @Transactional(readOnly = true)
    public PartListResponse listParts(UUID vehicleId) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        List<PartResponse> result =
                parts.findAllByVehicleOrderByInstalledAtDescNameAsc(vehicle).stream().map(this::toResponse).toList();
        return new PartListResponse(result);
    }

    @Transactional
    public PartResponse createPart(UUID vehicleId, CreatePartRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        Part part = new Part();
        part.setVehicle(vehicle);
        part.setName(request.name());
        part.setCategory(request.category());
        part.setInstalledAt(request.installedAt());
        part.setInstalledMileageKm(request.installedMileageKm());
        part.setExpectedLifetimeKm(request.expectedLifetimeKm());
        part.setDescription(request.description());
        part.setCost(request.cost());
        if (request.photoUrls() != null) {
            part.getPhotoUrls().addAll(request.photoUrls());
        }
        refreshLifetime(vehicle, part);
        PartResponse response = toResponse(parts.save(part));
        metrics.recordPartCreated();
        return response;
    }

    @Transactional
    public PartResponse updatePart(UUID vehicleId, UUID partId, UpdatePartRequest request) {
        Vehicle vehicle = vehicles.requireOwnedVehicle(vehicleId);
        Part part = parts.findByIdAndVehicle(partId, vehicle)
                .orElseThrow(() -> new ResourceNotFoundException("Part not found"));
        if (StringUtils.hasText(request.name())) {
            part.setName(request.name());
        }
        if (request.category() != null) {
            part.setCategory(request.category());
        }
        if (request.installedAt() != null) {
            part.setInstalledAt(request.installedAt());
        }
        if (request.installedMileageKm() != null) {
            part.setInstalledMileageKm(request.installedMileageKm());
        }
        if (request.expectedLifetimeKm() != null) {
            part.setExpectedLifetimeKm(request.expectedLifetimeKm());
        }
        if (request.description() != null) {
            part.setDescription(request.description());
        }
        if (request.cost() != null) {
            part.setCost(request.cost());
        }
        if (request.photoUrls() != null) {
            part.getPhotoUrls().clear();
            part.getPhotoUrls().addAll(request.photoUrls());
        }
        refreshLifetime(vehicle, part);
        return toResponse(part);
    }

    @Transactional
    public void refreshPartsForVehicle(Vehicle vehicle) {
        parts.findAllByVehicleOrderByInstalledAtDescNameAsc(vehicle)
                .forEach(part -> refreshLifetime(vehicle, part));
    }

    @Transactional
    public void createPartsFromMaintenance(
            Vehicle vehicle,
            java.time.OffsetDateTime eventDateTime,
            Integer mileageKm,
            String description,
            List<String> replacedParts) {
        List<String> names = maintenancePartNames(description, replacedParts);
        if (names.isEmpty()) {
            return;
        }
        for (String name : names) {
            Part part = new Part();
            part.setVehicle(vehicle);
            part.setName(name);
            part.setCategory(categoryFor(name));
            part.setInstalledAt(eventDateTime.toLocalDate());
            part.setInstalledMileageKm(mileageKm);
            part.setDescription("Created from maintenance record");
            refreshLifetime(vehicle, part);
            parts.save(part);
            metrics.recordPartCreated();
        }
    }

    private List<String> maintenancePartNames(String description, List<String> replacedParts) {
        Set<String> names = new LinkedHashSet<>();
        if (replacedParts != null) {
            replacedParts.stream()
                    .map(this::cleanPartName)
                    .filter(StringUtils::hasText)
                    .forEach(names::add);
        }
        if (description != null) {
            for (String line : description.lines().toList()) {
                String stripped = line.strip();
                if (stripped.regionMatches(true, 0, "Replaced parts:", 0, "Replaced parts:".length())) {
                    String value = stripped.substring("Replaced parts:".length());
                    List.of(value.split(",")).stream()
                            .map(this::cleanPartName)
                            .filter(StringUtils::hasText)
                            .forEach(names::add);
                }
            }
        }
        return List.copyOf(names);
    }

    private String cleanPartName(String name) {
        if (name == null) {
            return "";
        }
        String cleaned = name.replaceAll("\\s+", " ").strip();
        return cleaned.length() > 255 ? cleaned.substring(0, 255) : cleaned;
    }

    private PartCategory categoryFor(String name) {
        String normalized = name.toLowerCase(Locale.ROOT);
        if ((normalized.contains("oil") || normalized.contains("масл"))
                && (normalized.contains("filter") || normalized.contains("фильтр"))) {
            return PartCategory.OIL_FILTER;
        }
        if (normalized.contains("air filter")
                || normalized.contains("воздуш")
                || (normalized.contains("filter") && normalized.contains("air"))) {
            return PartCategory.AIR_FILTER;
        }
        if (normalized.contains("pad") || normalized.contains("brake") || normalized.contains("колод")) {
            return PartCategory.BRAKE_PADS;
        }
        if (normalized.contains("timing") || normalized.contains("belt") || normalized.contains("грм") || normalized.contains("ремен")) {
            return PartCategory.TIMING_BELT;
        }
        if (normalized.contains("battery") || normalized.contains("аккум")) {
            return PartCategory.BATTERY;
        }
        if (normalized.contains("oil") || normalized.contains("масл")) {
            return PartCategory.ENGINE_OIL;
        }
        return PartCategory.OTHER;
    }

    private void refreshLifetime(Vehicle vehicle, Part part) {
        var lifetime = lifetimeService.calculate(new PartLifetimeRequest(
                vehicle.getMileageKm(), part.getInstalledMileageKm(), part.getExpectedLifetimeKm(), part.getCategory()));
        part.setRemainingKm(lifetime.remainingKm());
        part.setRemainingPercent(lifetime.remainingPercent());
        part.setStatus(lifetime.status());
    }

    private PartResponse toResponse(Part part) {
        return new PartResponse(
                part.getId(),
                part.getName(),
                part.getCategory(),
                part.getInstalledAt(),
                part.getInstalledMileageKm(),
                part.getExpectedLifetimeKm(),
                part.getRemainingKm(),
                part.getRemainingPercent(),
                part.getStatus(),
                part.getDescription(),
                part.getCost(),
                List.copyOf(part.getPhotoUrls()));
    }
}