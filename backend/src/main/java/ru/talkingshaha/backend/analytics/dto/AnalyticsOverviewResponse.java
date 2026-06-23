package ru.talkingshaha.backend.analytics.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import ru.talkingshaha.backend.analytics.model.AnalyticsPeriod;

public record AnalyticsOverviewResponse(
        AnalyticsPeriod period,
        BigDecimal totalExpenses,
        String currency,
        Map<String, BigDecimal> expensesByCategory,
        List<MonthlyExpenseResponse> monthlyExpenses,
        List<SeasonalExpenseResponse> seasonalExpenses,
        CostPerKilometerResponse costPerKilometer,
        FuelAnalyticsResponse fuel,
        HistoryAnalysisResponse historyAnalysis,
        boolean hasData) {
}