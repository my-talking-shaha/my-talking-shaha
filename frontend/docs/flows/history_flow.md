# Vehicle History / Timeline Flow

## User Stories

Covers:
- DATA-01 vehicle history upload and timeline CRUD.

## Screens

- History timeline.
- Add event type selector.
- Add/edit trip form.
- Add/edit refueling form.
- Add/edit repair form.
- Add/edit maintenance form.
- Event details screen or bottom sheet.

## Timeline Flow

1. User opens `/vehicle/:vehicleId/history`.
2. Client fetches timeline events for selected vehicle.
3. Events are shown in chronological order.
4. Events can be grouped by month/date.
5. User can search and filter by event type.

## Event Types

### Repair
Fields:
- date;
- mileage;
- description;
- cost;
- replaced parts;
- photos optional.

### Refueling
Fields:
- date;
- mileage;
- liters;
- cost;
- fuel type.

### Trip
Fields:
- date;
- start mileage;
- end mileage;
- route optional.

### Maintenance
Fields:
- date;
- mileage;
- description/service type;
- cost;
- replaced/serviced parts optional.

## Add Event Flow

1. User taps add button.
2. User selects event type.
3. Matching form opens.
4. User fills fields.
5. Client validates fields.
6. Client sends create event request.
7. Timeline updates without app restart.
8. Vehicle dashboard and analytics may refresh/invalidate.

## Edit/Delete Flow

1. User makes long tap or swipe to left.
2. User chooses edit or delete.
3. Edit updates event and refreshes timeline.
4. Delete requires confirmation and refreshes timeline.

## Mileage Validation

- New mileage cannot be lower than previous known vehicle mileage unless backend explicitly supports corrections.
- Trip end mileage must be >= start mileage.
- If backend rejects mileage, show field-level error.

## Acceptance Criteria

- User can add repair, refueling, and trip records.
- Records are attached to selected vehicle.
- Records are shown in chronological timeline.
- User can edit/delete any record.
- Timeline updates after adding without app restart.
- Mileage fields are validated.
