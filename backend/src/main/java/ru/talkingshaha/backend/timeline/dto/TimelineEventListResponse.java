package ru.talkingshaha.backend.timeline.dto;

import java.util.List;

public record TimelineEventListResponse(List<TimelineEventResponse> events) {
}
