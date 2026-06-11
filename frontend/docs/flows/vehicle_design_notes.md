# Vehicle Dashboard Design Notes

## Screen From Design

- Accord to `docs/design/screenshots/01_vehicle.jpg` for design example

## Visual Structure

The vehicle dashboard is the main cockpit screen for a selected car.

Sections:
1. Top app bar with menu/back icon and centered title `Моя Шаха`.
2. Vehicle hero image card with title overlay.
3. Metric cards for mileage and engine.
4. VIN card with copy icon.
5. Embedded parts feature widget: maintenance forecast.
6. Recent events list.
7. Bottom navigation.

## Dashboard Content

Show:
- vehicle image/photo or fallback avatar;
- brand/model;
- current mileage;
- engine type;
- VIN if available;
- current condition/status;
- embedded parts feature widget;
- last 5 timeline events;
- shortcuts through bottom navigation.

## Parts Widget on Dashboard

The dashboard includes the `MaintenanceForecastCard` from the `parts` feature.
This card must not contain vehicle-dashboard-specific business logic.
It receives data from the `parts` feature/provider.

If parts data is unavailable:
- show skeleton/placeholder;
- or hide the card with a clear empty state;
- do not crash the dashboard.

## Recent Events

Recent events use compact cards with:
- colored circular icon;
- event title;
- short description;
- time/date;
- optional warning/accent severity.

Examples from design:
- completed trip;
- refuel;
- oil replacement;
- low battery warning;
- remote start.

## Implementation Notes

- Use `VehicleHeroCard`, `VehicleMetricCard`, `VinCard`, `MaintenanceForecastCard`, and `RecentEventTile`.
- Keep dashboard scrollable.
- Keep important vehicle data above recent events.
