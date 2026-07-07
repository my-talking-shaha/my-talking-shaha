package ru.talkingshaha.backend.chat.service;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.talkingshaha.backend.chat.dto.TripDataCollectionRequest;
import ru.talkingshaha.backend.chat.dto.TripEndRequest;
import ru.talkingshaha.backend.chat.dto.TripLifecycleResponse;
import ru.talkingshaha.backend.chat.dto.TripStartRequest;
import ru.talkingshaha.backend.chat.model.ChatSession;
import ru.talkingshaha.backend.timeline.dto.TimelineEventResponse;
import ru.talkingshaha.backend.timeline.service.TimelineEventService;
import ru.talkingshaha.backend.timeline.service.TimelineEventService.TripUpdate;

@Service
public class TripChatService {

    private static final String UNIT_END = "(?=$|\\s|[.,!?;:])";
    private static final Pattern DISTANCE_PATTERN = Pattern.compile(
            "(-?\\d+)\\s*(?:km|kilometer|kilometers|км|километр|километра|километров)" + UNIT_END,
            Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final Pattern DURATION_PATTERN = Pattern.compile(
            "(-?\\d+)\\s*(?:min|mins|minute|minutes|м|мин|минут|минуты)" + UNIT_END,
            Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final Pattern HOURS_PATTERN = Pattern.compile(
            "(-?\\d+)\\s*(?:h|hour|hours|час|часа|часов)" + UNIT_END,
            Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    private static final Pattern FUEL_PATTERN = Pattern.compile(
            "(-?\\d+(?:[.,]\\d+)?)\\s*(?:l|liter|liters|л|литр|литра|литров)" + UNIT_END,
            Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);

    private final ChatService chat;
    private final TimelineEventService timelineEvents;

    public TripChatService(ChatService chat, TimelineEventService timelineEvents) {
        this.chat = chat;
        this.timelineEvents = timelineEvents;
    }

    @Transactional
    public TripLifecycleResponse start(UUID vehicleId, TripStartRequest request) {
        ChatSession session = chat.activeSession(vehicleId, ChatLanguage.EN);
        TimelineEventResponse trip = timelineEvents.startChatTrip(
                vehicleId,
                session,
                request.startedAt() == null ? OffsetDateTime.now() : request.startedAt(),
                request.notes());
        return new TripLifecycleResponse(
                trip.id(),
                "Trip started. I saved the start time and will keep the record even if details are added later.",
                List.of("distanceKm", "fuelLiters", "durationMinutes"),
                Map.of(),
                trip);
    }

    @Transactional
    public TripLifecycleResponse end(UUID vehicleId, UUID tripId, TripEndRequest request) {
        ChatSession session = chat.activeSession(vehicleId, ChatLanguage.EN);
        Map<String, Object> extracted = new LinkedHashMap<>();
        putIfPresent(extracted, "distanceKm", request.distanceKm());
        putIfPresent(extracted, "durationMinutes", request.durationMinutes());
        putIfPresent(extracted, "fuelLiters", request.fuelLiters());
        putIfPresent(extracted, "notes", request.notes());
        TimelineEventResponse trip = timelineEvents.updateChatTrip(
                vehicleId,
                tripId,
                session,
                new TripUpdate(
                        request.endedAt() == null ? OffsetDateTime.now() : request.endedAt(),
                        request.distanceKm(),
                        request.durationMinutes(),
                        request.fuelLiters(),
                        request.notes()));
        List<String> missing = timelineEvents.missingRequiredTripFields(vehicleId, tripId);
        return new TripLifecycleResponse(
                trip.id(),
                missing.isEmpty()
                        ? "Trip finished and saved."
                        : "Trip finished and auto-saved as partial. Send the missing details when you have them.",
                missing,
                extracted,
                trip);
    }

    @Transactional
    public TripLifecycleResponse collectData(UUID vehicleId, UUID tripId, TripDataCollectionRequest request) {
        ChatSession session = chat.activeSession(vehicleId, ChatLanguage.EN);
        Map<String, Object> extracted = extract(request.text());
        TimelineEventResponse trip = timelineEvents.updateChatTrip(
                vehicleId,
                tripId,
                session,
                new TripUpdate(
                        null,
                        integer(extracted.get("distanceKm")),
                        integer(extracted.get("durationMinutes")),
                        decimal(extracted.get("fuelLiters")),
                        note(request.text(), extracted)));
        List<String> missing = timelineEvents.missingRequiredTripFields(vehicleId, tripId);
        return new TripLifecycleResponse(
                trip.id(),
                extracted.isEmpty()
                        ? "I could not confidently extract trip details, so I auto-saved the trip as partial."
                        : "I extracted and saved the trip details.",
                missing,
                extracted,
                trip);
    }

    private Map<String, Object> extract(String text) {
        Map<String, Object> values = new LinkedHashMap<>();
        firstInteger(text, DISTANCE_PATTERN).ifPresent(value -> values.put("distanceKm", value));
        durationMinutes(text).ifPresent(value -> values.put("durationMinutes", value));
        firstDecimal(text, FUEL_PATTERN).ifPresent(value -> values.put("fuelLiters", value));
        return values;
    }

    private java.util.Optional<Integer> durationMinutes(String text) {
        java.util.Optional<Integer> explicitMinutes = firstInteger(text, DURATION_PATTERN);
        if (explicitMinutes.isPresent()) {
            return explicitMinutes;
        }
        return firstInteger(text, HOURS_PATTERN).map(hours -> hours * 60);
    }

    private java.util.Optional<Integer> firstInteger(String text, Pattern pattern) {
        Matcher matcher = pattern.matcher(text);
        if (!matcher.find()) {
            return java.util.Optional.empty();
        }
        return java.util.Optional.of(Integer.parseInt(matcher.group(1)));
    }

    private java.util.Optional<BigDecimal> firstDecimal(String text, Pattern pattern) {
        Matcher matcher = pattern.matcher(text);
        if (!matcher.find()) {
            return java.util.Optional.empty();
        }
        return java.util.Optional.of(new BigDecimal(matcher.group(1).replace(',', '.')));
    }

    private Integer integer(Object value) {
        return value instanceof Integer integer ? integer : null;
    }

    private BigDecimal decimal(Object value) {
        return value instanceof BigDecimal decimal ? decimal : null;
    }

    private String note(String text, Map<String, Object> extracted) {
        return extracted.isEmpty() ? null : text;
    }

    private void putIfPresent(Map<String, Object> target, String key, Object value) {
        if (value != null) {
            target.put(key, value);
        }
    }
}
