# History Design Notes

## Screens From Design

- Accord to `docs/design/screenshots/history/` for design example

## Timeline Screen

Visual structure:
- top app bar/title `Service History`;
- search field;
- filter/settings icon;
- category chips;
- date/month grouping;
- event cards;
- floating add button;
- bottom navigation.

Event card content:
- icon circle;
- event title;
- description/details;
- date/time;
- amount or distance when relevant.

Events should be visually categorized:
- fuel/refuel;
- repair;
- maintenance;
- trip;
- warning.

## Add Record Forms

The add record screens share a common structure:
- top bar with back icon;
- title such as `New trip`, `New refuel`, or maintenance form;
- record-type tabs;
- dark inputs;
- optional photo attachment for maintenance/repair;
- primary `Save` button.

## Form Types

### Maintenance/Repair

Fields may include:
- date;
- mileage;
- category/type;
- service station;
- description;
- cost;
- photo optional.

### Refuel

Fields may include:
- date;
- mileage;
- fuel type;
- liters;
- price/cost;
- gas station.

### Trip

Fields may include:
- date;
- start mileage;
- end mileage;
- route optional.

## Implementation Notes

- Use `HistoryEventCard` for list items.
- Use `HistoryFilterChips` for filters.
- Use `HistoryFormScaffold` for all add/edit forms.
- Forms must be scrollable and keyboard-safe.
- Validation must prevent invalid mileage values.
