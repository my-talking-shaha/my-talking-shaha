# Vehicle History / Timeline Flow

## User Stories

Covers:
- DATA-01 vehicle history upload and timeline CRUD.

## Screens

- History timeline.
- Add event type selector.
- Add trip form.
- Add refueling form.
- Add service form.
- Add part event form.
- Event details screen or bottom sheet.

## Timeline Flow

1. User opens `/vehicle/:vehicleId/history`.
2. Client fetches timeline events for selected vehicle.
3. Events are shown in chronological order.
4. Events can be grouped by month/date.
5. User can search and filter by event type.

## Event Types

### Part replacement/update
Fields:
- date and time;
- mileage;
- replaced/updated part name;
- description optional;
- cost optional;
- photo optional.

### Refueling
Fields:
- date and time;
- mileage;
- liters;
- cost;
- fuel type.

### Trip
Fields:
- date and time;
- start mileage optional;
- end mileage;
- route optional.
- duration.

### Service
Fields:
- date and time;
- mileage;
- title;
- description optional;
- cost optional;
- photo optional.

## Add Event Flow

1. User taps add button.
2. User selects event type.
3. Matching form opens.
4. User fills fields.
5. Client validates fields.
6. Client sends create event request.
7. Timeline updates without app restart.
8. Vehicle dashboard and analytics may refresh/invalidate.

## Mileage Validation

- New mileage cannot be lower than previous known vehicle mileage unless backend explicitly supports corrections.
- Trip end mileage must be >= start mileage.
- If backend rejects mileage, show field-level error.

## Acceptance Criteria

- User can add refueling, trip, service, and part records.
- Records are attached to selected vehicle.
- Records are shown in chronological timeline.
- Timeline updates after adding without app restart.
- Mileage fields are validated.
