package ru.talkingshaha.backend.analytics.dto;

import java.math.BigDecimal;
import java.util.Map;

public record MonthlyExpenseResponse(
        String month,
        BigDecimal total,
        Map<String, BigDecimal> breakdownByCategory) {
}