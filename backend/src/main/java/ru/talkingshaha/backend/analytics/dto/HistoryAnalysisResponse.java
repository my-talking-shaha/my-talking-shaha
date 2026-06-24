package ru.talkingshaha.backend.analytics.dto;

import java.math.BigDecimal;

public record HistoryAnalysisResponse(
        Integer eventCount,
        Integer refuelCount,
        Integer tripCount,
        Integer maintenanceCount,
        Integer partEventCount,
        Integer totalTripKm,
        BigDecimal averageTripKm) {
}