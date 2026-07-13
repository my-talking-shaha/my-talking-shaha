# Parts Design Notes

## Screen/Widget From Design

- Accord to `docs/design/screenshots/01_parts.png` for a historical design
  example.
- same widget is also visible inside `01_vehicle.jpg` and `01_analytics.jpg`.

For structure-only refactors, the current runtime baseline in
`docs/flows/parts_behavior_and_design_baseline.md` is the source of truth for
behavior, colors, spacing, and typography.

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
- section title `MAINTENANCE FORECAST`;
- last updated label;
- next service forecast, e.g. `In 2,400 km`;
- approximate date;
- resource badge, e.g. `84% RESOURCE`;
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
