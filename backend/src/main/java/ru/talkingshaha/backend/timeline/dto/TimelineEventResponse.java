package ru.talkingshaha.backend.timeline.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.vehicle.model.FuelType;

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
