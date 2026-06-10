# Flutter Client Architecture Overview

## Product Context

My Talking Shaha is a Flutter client for a digital car twin platform. The client presents a garage, vehicle dashboards, timeline history, parts lifetime, analytics, notifications, settings, and AI chat.

The client must prioritize reliable product flows over speculative telemetry. Data shown in the app must come from user-entered data, backend-calculated aggregates, or documented API responses.

## Architecture Style

The project uses feature-first architecture with strict layer separation.

```text
lib/
  main.dart
  app/
    app.dart
    router/
      app_router.dart
      route_names.dart
    theme/
      app_theme.dart
      app_colors.dart
      app_typography.dart
  core/
    config/
      app_config.dart
    errors/
      app_failure.dart
      failure_mapper.dart
    network/
      api_client.dart
      api_exception.dart
      auth_interceptor.dart
    storage/
      token_storage.dart
    ui/
      app_card.dart
      app_scaffold.dart
      app_button.dart
      empty_state.dart
      error_state.dart
      status_chip.dart
    utils/
      date_formatters.dart
      currency_formatters.dart
      mileage_formatters.dart
  features/
    auth/
    garage/
    vehicle/
    history/
    parts/
    analytics/
    chat/
    notifications/
    settings/
```

## Feature Layer Structure

Each feature follows:

```text
features/<feature>/
  presentation/
    screens/
    widgets/
    controllers/
    state/
  domain/
    entities/
    repositories/
    use_cases/
  data/
    dto/
    datasources/
    repositories/
    mappers/
```

## Dependency Direction

```text
presentation -> domain -> data
```

- Presentation depends on domain contracts/use cases.
- Data implements domain repository contracts.
- Domain is pure Dart and framework-independent.
- Provider wiring can connect layers, but domain itself must not know Riverpod.

## Feature Responsibilities

### auth
Registration, login, logout, session state, Google auth hook, token storage integration.

### garage
List of user's vehicles, empty garage, add vehicle entry point, delete confirmation, vehicle selection.

### vehicle
Vehicle profile/dashboard, basic characteristics, condition summary, last events, status indicators.

### history
Timeline CRUD for trips, refueling, repairs, maintenance, filtering/search, event forms.

### parts
Installed parts, part catalog integration, remaining resource, replacement action, warnings by lifetime.

### analytics
Expenses, mileage dynamics, fuel consumption, cost per km, repair/refueling/maintenance aggregates.

### chat
Per-vehicle AI assistant, chat history, grounded responses, insufficient-data fallback, optional voice input.

### notifications
Warning/reminder list, push notification preferences, notification center.

### settings
Theme, localization, profile actions, logout, notification toggles.

## State Management

Use Riverpod.

- Dependencies: `Provider`.
- Simple async reads: `FutureProvider`.
- Screens with actions: `AsyncNotifier` / `Notifier`.
- UI states: immutable state classes.

State must be scoped by feature and, where needed, by `vehicleId`.

## Navigation

Use GoRouter.

Important routes:

```text
/auth/login
/auth/register
/garage
/garage/add
/vehicle/:vehicleId
/vehicle/:vehicleId/history
/vehicle/:vehicleId/history/add
/vehicle/:vehicleId/parts
/vehicle/:vehicleId/analytics
/vehicle/:vehicleId/chat
/notifications
/settings
```

Vehicle-specific screens must use the route `vehicleId`.

## API Layer

Feature data layers should use a shared core API client.

- API base URL comes from config.
- Auth token is attached centrally.
- DTOs parse JSON.
- Mappers convert DTOs to domain entities.
- Repositories expose domain entities.

## Error Handling

Use a shared app failure model:

```text
validation
unauthorized
forbidden
notFound
conflict
network
server
unknown
```

UI must convert failures into user-friendly messages.

## Digital Twin Boundary

The digital twin is built from:
- vehicle profile data;
- timeline events;
- installed parts and resources;
- analytics aggregates;
- warnings/recommendations;
- AI chat history.

Do not display real-time telemetry unless backend/API explicitly provides it.

## Testing Strategy

Prioritize:
- domain use case tests;
- mapper tests;
- controller tests;
- widget tests for critical screens/forms;
- navigation tests for auth and vehicle routes when feasible.

## Documentation Ownership

If a feature changes behavior, update:
- relevant `docs/flows/*.md`;
- relevant `docs/contracts/*.md`;
- `AGENTS.md` only when global rules change.
