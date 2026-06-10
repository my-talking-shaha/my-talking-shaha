# Vehicle Dashboard Flow

## User Stories

Covers:
- ACC-04 open vehicle details.
- STATUS-01 current condition.
- DATA-03 photo/3D representation, optional/Could.

## Screens

- Vehicle dashboard.
- Vehicle characteristics/details.
- Last events section.
- Current condition/status section.
- Embedded parts feature widget / maintenance forecast card.

## Open Vehicle Flow

1. User selects a vehicle from Garage.
2. App navigates to /vehicle/:vehicleId.
3. Client loads vehicle profile and dashboard summary.
4. Screen displays vehicle image/hero, characteristics, current condition, embedded parts feature widget, and recent events.

## Dashboard Content

Show:
- vehicle image/photo or fallback avatar;
- brand/model;
- current mileage;
- engine type;
- VIN if available;
- embedded parts feature widget with maintenance forecast and remaining lifetime indicators;
- last 5 timeline events;
- shortcut to history, parts, analytics, chat.

## Parts Feature Widget

The dashboard may include a reusable parts feature widget.

The widget can display:
- next maintenance forecast;
- closest required service;
- part remaining lifetime in kilometers and/or percent;
- warning/critical indicators for low remaining lifetime.

This widget belongs to the parts feature in architecture, but is rendered inside the vehicle dashboard UI.

If the parts feature is not implemented yet, the dashboard must show a placeholder or hide the section without breaking the screen.

## Photo/Avatar Flow

Priority: Could.

- If user uploaded photo, show it.
- If multiple photos exist, show gallery.
- If no photo exists, show model-based fallback image/avatar.
- Do not implement 3D model generation unless explicitly requested.

## Acceptance Criteria

- Dashboard shows vehicle image, brand/model, current mileage, engine type, and VIN if available.
- Parts feature widget is shown if implemented, otherwise it is safely placeholdered.
- Last events update after new timeline records.
