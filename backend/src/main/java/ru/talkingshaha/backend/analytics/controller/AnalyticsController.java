package ru.talkingshaha.backend.analytics.controller;

import java.time.LocalDate;
import java.util.UUID;

import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import ru.talkingshaha.backend.common.error.ApiError;
import ru.talkingshaha.backend.common.metrics.BusinessMetrics;
import ru.talkingshaha.backend.analytics.dto.AnalyticsOverviewResponse;
import ru.talkingshaha.backend.analytics.dto.MileageTrendResponse;
import ru.talkingshaha.backend.analytics.model.AnalyticsPeriod;
import ru.talkingshaha.backend.analytics.service.AnalyticsService;

@RestController
@RequestMapping("/api/v1/vehicles/{vehicleId}/analytics")
@ApiResponses({
        @ApiResponse(
                responseCode = "400",
                description = "Validation error",
                content = @Content(schema = @Schema(implementation = ApiError.class))),
        @ApiResponse(
                responseCode = "403",
                description = "Vehicle belongs to another user",
                content = @Content(schema = @Schema(implementation = ApiError.class))),
        @ApiResponse(
                responseCode = "404",
                description = "Vehicle not found",
                content = @Content(schema = @Schema(implementation = ApiError.class)))
})
public class AnalyticsController {

    private final AnalyticsService analytics;
    private final BusinessMetrics metrics;

    public AnalyticsController(AnalyticsService analytics, BusinessMetrics metrics) {
        this.analytics = analytics;
        this.metrics = metrics;
    }

    @GetMapping
    public AnalyticsOverviewResponse overview(
            @PathVariable UUID vehicleId,
            @RequestParam(defaultValue = "ALL_TIME") AnalyticsPeriod period,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        metrics.recordAnalyticsViewed("overview");
        return analytics.overview(vehicleId, period, startDate, endDate);
    }

    @GetMapping("/mileage-trend")
    public MileageTrendResponse mileageTrend(
            @PathVariable UUID vehicleId,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer month) {
        metrics.recordAnalyticsViewed("mileage_trend");
        return analytics.mileageTrend(vehicleId, year, month);
    }
}