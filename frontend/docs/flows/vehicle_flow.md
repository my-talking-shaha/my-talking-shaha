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

## Open Vehicle Flow

1. User selects vehicle from Garage.
2. App navigates to `/vehicle/:vehicleId`.
3. Client loads vehicle profile and dashboard summary.
4. Screen displays vehicle image/hero, characteristics, status, and recent events.

## Dashboard Content

Show:
- vehicle image/photo or fallback avatar;
- brand/model;
- year;
- current mileage;
- engine type;
- VIN if available;
- last maintenance date if available;
- active warnings count;
- overall status: OK / warning / critical / unknown;
- last 5 timeline events;
- shortcut to history, parts, analytics, chat.

## Status Indicator

Status meaning:
- OK: no active warnings, critical resources above thresholds.
- Warning: attention required, resource below warning threshold.
- Critical: resource expired or urgent issue.
- Unknown: insufficient data.

Client should prefer backend-provided status. If local fallback is used, it must be clearly derived from available data only.

## Characteristics Flow

1. User opens characteristics/details.
2. App displays all available vehicle fields.
3. Optional edit flow can be implemented if backend supports it.

## Photo/Avatar Flow

Priority: Could.

- If user uploaded photo, show it.
- If multiple photos exist, show gallery.
- If no photo exists, show model-based fallback image/avatar.
- Do not implement 3D model generation unless explicitly requested.

## Acceptance Criteria

- Vehicle card opens a detail page.
- Dashboard shows current mileage, last maintenance date, and active warnings where available.
- Overall status is visible.
- User can tap blocks for detailed information when supported.
- Last events update after new timeline records.
