package ru.talkingshaha.backend.analytics.controller;

import java.util.UUID;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import ru.talkingshaha.backend.analytics.dto.AnalyticsOverviewResponse;
import ru.talkingshaha.backend.analytics.model.AnalyticsPeriod;
import ru.talkingshaha.backend.analytics.service.AnalyticsService;

@RestController
@RequestMapping("/api/v1/vehicles/{vehicleId}/analytics")
public class AnalyticsController {

    private final AnalyticsService analytics;

    public AnalyticsController(AnalyticsService analytics) {
        this.analytics = analytics;
    }

    @GetMapping
    public AnalyticsOverviewResponse overview(
            @PathVariable UUID vehicleId,
            @RequestParam(defaultValue = "ALL_TIME") AnalyticsPeriod period) {
        return analytics.overview(vehicleId, period);
    }
}