package ru.talkingshaha.backend.vehicle.dto;

import java.time.OffsetDateTime;
import java.util.List;

import ru.talkingshaha.backend.part.dto.PartResponse;
import ru.talkingshaha.backend.part.model.PartStatus;

public record VehicleDashboardResponse(
        VehicleResponse vehicle, MaintenanceForecast maintenanceForecast, List<RecentEventResponse> recentEvents) {

    public record MaintenanceForecast(
            PartStatus overallStatus,
            Integer nextServiceInKm,
            OffsetDateTime updatedAt,
            List<PartResponse> parts) {
    }

    public record RecentEventResponse(
            String id, String type, String title, String subtitle, OffsetDateTime eventDateTime) {
    }
}