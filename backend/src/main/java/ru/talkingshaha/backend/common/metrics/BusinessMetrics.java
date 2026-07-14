package ru.talkingshaha.backend.common.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import java.util.List;
import org.springframework.stereotype.Component;
import ru.talkingshaha.backend.chat.repository.ChatMessageRepository;
import ru.talkingshaha.backend.part.repository.PartRepository;
import ru.talkingshaha.backend.timeline.model.TimelineEventType;
import ru.talkingshaha.backend.timeline.repository.TimelineEventRepository;
import ru.talkingshaha.backend.user.repository.AppUserRepository;
import ru.talkingshaha.backend.vehicle.repository.VehicleRepository;

@Component
public class BusinessMetrics {

    private static final String DEMO_EMAIL = "demo@talkingshaha.local";
    private static final String ANALYTICS_OVERVIEW = "overview";
    private static final String ANALYTICS_MILEAGE_TREND = "mileage_trend";

    private final MeterRegistry registry;
    private final Counter registrations;
    private final Counter vehiclesCreated;
    private final Counter partsCreated;
    private final Counter chatMessagesSent;

    public BusinessMetrics(
            MeterRegistry registry,
            AppUserRepository users,
            VehicleRepository vehicles,
            TimelineEventRepository timelineEvents,
            PartRepository parts,
            ChatMessageRepository chatMessages) {
        this.registry = registry;
        this.registrations = Counter.builder("talkingshaha_users_registered")
                .description("Total successful user registrations")
                .register(registry);
        this.vehiclesCreated = Counter.builder("talkingshaha_vehicle_creations")
                .description("Total vehicles created")
                .register(registry);
        this.partsCreated = Counter.builder("talkingshaha_part_creations")
                .description("Total vehicle parts created")
                .register(registry);
        this.chatMessagesSent = Counter.builder("talkingshaha_chat_user_messages")
                .description("Total user messages sent to the car chat")
                .register(registry);

        registry.gauge("talkingshaha_users", users, repository -> repository.countByEmailNot(DEMO_EMAIL));
        registry.gauge("talkingshaha_vehicles", vehicles, repository -> repository.countByOwnerEmailNot(DEMO_EMAIL));
        registry.gauge("talkingshaha_timeline_events", timelineEvents, TimelineEventRepository::count);
        registry.gauge("talkingshaha_parts", parts, PartRepository::count);
        registry.gauge("talkingshaha_chat_messages", chatMessages, ChatMessageRepository::count);

        for (TimelineEventType type : TimelineEventType.values()) {
            registry.gauge(
                    "talkingshaha_timeline_events_by_type",
                    List.of(io.micrometer.core.instrument.Tag.of("type", type.name())),
                    timelineEvents,
                    repository -> repository.countByTypeAndVehicleOwnerEmailNot(type, DEMO_EMAIL));
            timelineEventCreations(type);
        }
        analyticsViews(ANALYTICS_OVERVIEW);
        analyticsViews(ANALYTICS_MILEAGE_TREND);
    }

    public void recordRegistration() {
        registrations.increment();
    }

    public void recordVehicleCreated() {
        vehiclesCreated.increment();
    }

    public void recordTimelineEventCreated(TimelineEventType type) {
        timelineEventCreations(type).increment();
    }

    public void recordPartCreated() {
        partsCreated.increment();
    }

    public void recordChatUserMessage() {
        chatMessagesSent.increment();
    }

    public void recordAnalyticsViewed(String view) {
        analyticsViews(view).increment();
    }

    private Counter timelineEventCreations(TimelineEventType type) {
        return Counter.builder("talkingshaha_timeline_event_creations")
                .description("Total timeline events created")
                .tag("type", type.name())
                .register(registry);
    }

    private Counter analyticsViews(String view) {
        return Counter.builder("talkingshaha_analytics_views")
                .description("Total analytics endpoint views")
                .tag("view", view)
                .register(registry);
    }
}