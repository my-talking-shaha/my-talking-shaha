# Parts Design Notes

## Screen/Widget From Design

- `Parts-parts_widget.png`
- same widget is also visible inside `Vehicle-dashboard.jpg` and `Analytics.jpg`.

## Feature Meaning

`parts` is an internal reusable feature responsible for vehicle parts, their remaining lifetime, status, and maintenance forecast.
It is not required to be a separate bottom navigation tab.

It can be rendered as:
- a widget on the vehicle dashboard;
- a widget on the analytics screen;
- a details/list screen if needed later;
- data for notifications and AI chat.

## Maintenance Forecast Card

The card displays:
- section title `ПРОГНОЗ ОБСЛУЖИВАНИЯ`;
- last updated label;
- next service forecast, e.g. `Через 2,400 км`;
- approximate date;
- resource badge, e.g. `84% РЕСУРС`;
- part rows with remaining km/percent and progress bars.

Part examples:
- brake pads;
- engine oil;
- timing belt.

## Status Colors

- OK/normal: primaryLight or cyan.
- Warning: amber.
- Critical: red/pink.
- Unknown/no lifetime: muted gray.

## Implementation Notes

- Use `MaintenanceForecastCard` as the main public widget of the feature.
- Use `PartResourceRow` for each part.
- Use `ResourceBadge` for the percentage box.
- The widget should accept `vehicleId` or a typed view model.
- Business rules should live in domain/use cases or backend, not inside UI.

## Required States

- loading;
- loaded with parts;
- empty/no parts configured;
- error;
- unknown lifetime for individual part.
