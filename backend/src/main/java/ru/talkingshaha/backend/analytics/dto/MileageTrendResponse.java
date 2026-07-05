package ru.talkingshaha.backend.analytics.dto;

import java.util.List;

public record MileageTrendResponse(
        int year,
        Integer month,
        List<MileageTrendPointResponse> points,
        boolean hasData) {
}
