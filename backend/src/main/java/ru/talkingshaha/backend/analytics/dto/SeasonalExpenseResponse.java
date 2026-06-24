package ru.talkingshaha.backend.analytics.dto;

import java.math.BigDecimal;

public record SeasonalExpenseResponse(String season, BigDecimal total) {
}