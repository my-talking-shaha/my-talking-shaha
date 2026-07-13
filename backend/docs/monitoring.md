# Monitoring

The backend exposes Spring Boot Actuator and Micrometer metrics for Prometheus:

```text
/actuator/prometheus
```

The endpoint is available without an application JWT so that Prometheus can
scrape it. In the local Docker stack, Prometheus reaches it through the Docker
network and Grafana reads from Prometheus.

## Dashboard

The local Grafana dashboard is intentionally small:

- backend health;
- API request rate by method, path, and status;
- API max latency;
- current users and vehicles;
- users over time;
- registrations over time;
- vehicles created over time;
- timeline events by type over time;
- chat and analytics activity over time;
- simple business action counters since backend start.

It does not include every JVM metric by default because the current dashboard is
meant for project reporting and quick service checks.

## Business Metrics

The backend currently publishes these product-oriented metrics:

```text
talkingshaha_users
talkingshaha_vehicles
talkingshaha_timeline_events
talkingshaha_timeline_events_by_type{type="..."}
talkingshaha_parts
talkingshaha_chat_messages
talkingshaha_users_registered_total
talkingshaha_vehicle_creations_total
talkingshaha_timeline_event_creations_total{type="..."}
talkingshaha_part_creations_total
talkingshaha_chat_user_messages_total
talkingshaha_analytics_views_total{view="..."}
```

Gauge metrics read current counts from existing repositories. The `users` and
`vehicles` dashboard panels exclude the local demo account. 
Counter metrics increase only after successful backend operations and reset when
the backend process restarts. Time-based action charts round Prometheus
`increase(...)` values to whole events.

## Deployment

Prometheus and Grafana are internal monitoring tools, they are not part of the
APK.