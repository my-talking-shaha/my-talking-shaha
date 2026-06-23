package ru.talkingshaha.backend.analytics.dto;

import java.math.BigDecimal;

public record CostPerKilometerResponse(
        Integer totalKm,
        BigDecimal totalExpenses,
        BigDecimal costPerKm) {
}