# Parts and Remaining Lifetime Flow

## Feature Meaning

`parts` is an internal product feature responsible for vehicle parts, their installation data, remaining lifetime, status, and maintenance forecast.

It is not required to be a separate bottom navigation tab.

The feature can be displayed as:

- a widget on the vehicle dashboard;
- a widget on the analytics screen;
- a data source for AI chat and notifications.

## User Stories

Covers:

- DATA-01: update parts and condition, Should.
- STATUS-02: remaining part lifetime, Must.
- NOTIF-01: warning notifications based on low remaining lifetime, Could.
- CHAT-01: AI answers based on vehicle data and rules, Must.

## Screens and UI Entry Points

Possible UI entry points:

- embedded parts widget on `/vehicle/:vehicleId`;
- embedded maintenance forecast card on `/vehicle/:vehicleId/analytics`;
- optional part details screen: `/vehicle/:vehicleId/parts/:partId`;
- add/edit part forms if the feature is implemented beyond read-only display.

## Parts Widget Flow

1. User opens vehicle dashboard or analytics screen.
2. Client loads parts summary or maintenance forecast for selected vehicle.
3. Widget displays next maintenance forecast and most important parts.
4. Each part displays name, remaining km/%, and status.
5. User can tap a part or edit icon if detailed parts management is available.

## Parts List Flow

1. User opens `/vehicle/:vehicleId/parts` or taps the dashboard parts section.
2. Client fetches installed parts for selected vehicle.
3. Each part displays name, install date, install mileage, lifetime, remaining km/% and status.
4. Parts without lifetime display `Ресурс не задан`.

## Remaining Lifetime Formula

```text
remainingKm = initialLifetimeKm - (currentVehicleMileage - installedAtMileage)
```

Status:
- OK: remaining > 10%.
- Warning: remaining < 10% and > 0.
- Critical: remaining <= 0.
- Unknown: lifetime is not set.

Prefer backend-provided status if available. Client fallback must use this formula only for display.

## Add Part Flow

1. User taps add part.
2. User enters/selects part name.
3. User enters install date and install mileage.
4. User enters lifetime km or selects catalog item with default lifetime.
5. Client validates and submits.
6. Part appears in parts list.
7. Dashboard and analytics widgets refresh.

## Catalog Flow

Priority: Should.

Examples:

- oil;
- oil filter;
- air filter;
- timing belt;
- brake pads;
- battery;
- spark plugs;
- tires.

When selected, default lifetime may be prefilled if known.

## Replace Part Flow

1. User opens part details or taps replace action.
2. User taps `Заменена` / replace.
3. User enters new date and mileage.
4. Backend creates replacement record and may create timeline event.
5. Parts list, dashboard widget, analytics widget, and timeline refresh.

## Relationship With Other Features

`vehicle` uses parts to show maintenance forecast on the dashboard.

`analytics` uses parts to show service readiness and critical components.

`history` may receive timeline events when a part is replaced.

`notifications` uses parts to warn about low remaining lifetime.

`chat` uses parts data to answer questions like:

- “Когда менять масло?”
- “Что нужно обслужить в первую очередь?”
- “Какие детали скоро закончат ресурс?”

## Acceptance Criteria

- Remaining resource is visible in km or percent.
- `Ресурс не задан` appears for missing lifetime.
- Warning and critical thresholds are visually clear.
- User can manually correct lifetime if edit flow is implemented.
- Replace action creates/updates records according to backend contract.
- Parts widget can be reused on dashboard and analytics without duplicating business logic.
