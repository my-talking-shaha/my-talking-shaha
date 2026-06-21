package ru.talkingshaha.backend.timeline.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.vehicle.model.FuelType;

/**
 * Unified response for any timeline event.
 *
 * <p>This shape is polymorphic over {@link TimelineEventType}: only the fields relevant to
 * the concrete event type are populated, the rest are {@code null}. Refuel events use
 * {@code liters}/{@code fuelType}/{@code fuelName}/{@code stationName} and {@code cost};
 * trip events use {@code startMileageKm}/{@code endMileageKm}/{@code distanceKm}/{@code route}/
 * {@code durationMinutes}; maintenance events use {@code name}/{@code description}/
 * {@code photoUrls} and {@code cost}.
 */
public record TimelineEventResponse(
        UUID id,
        TimelineEventType type,
        String title,
        OffsetDateTime eventDateTime,
        BigDecimal cost,
        Integer mileageKm,
        BigDecimal liters,
        FuelType fuelType,
        String fuelName,
        String stationName,
        Integer startMileageKm,
        Integer endMileageKm,
        Integer distanceKm,
        String route,
        Integer durationMinutes,
        String name,
        String description,
        List<String> photoUrls) {
}
