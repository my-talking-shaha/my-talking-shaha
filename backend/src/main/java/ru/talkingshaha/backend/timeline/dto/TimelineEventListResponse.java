package ru.talkingshaha.backend.timeline.dto;

import java.util.List;

/**
 * Wrapper response holding a vehicle's timeline events, most recent first.
 */
public record TimelineEventListResponse(List<TimelineEventResponse> events) {
}
