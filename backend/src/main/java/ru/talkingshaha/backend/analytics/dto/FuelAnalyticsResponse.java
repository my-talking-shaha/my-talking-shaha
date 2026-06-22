package ru.talkingshaha.backend.analytics.dto;

import java.math.BigDecimal;

public record FuelAnalyticsResponse(
        BigDecimal totalLiters,
        BigDecimal averageConsumptionLitersPer100Km) {
}