# Vehicle History / Timeline Flow

## User Stories

Covers:
- DATA-01 vehicle history upload and timeline CRUD.

## Screens

- History timeline.
- Add event type selector.
- Add trip form.
- Add refueling form.
- Add recharge form for electric vehicles.
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

### Recharge
For electric vehicles, the first event type uses recharge wording and the
dedicated recharge API endpoint.

Fields:
- date and time;
- mileage;
- energy in kWh;
- cost;
- charger type.

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

For service/repair photos on native platforms, the client first persists the
selected files in the device cache and then uploads those cached files with the
multipart create request. After creation, the temporary cache is bound to the
server event id. Photo controls are unavailable on web and read-only while an
existing event is edited because the backend PATCH contract does not change
attachments. Timeline photo rendering prefers cached files and falls back to
backend `photoUrls`; deleting an event removes its backend photos and the
matching local cache.

## Mileage Validation

- New mileage cannot be lower than previous known vehicle mileage unless backend explicitly supports corrections.
- Trip end mileage must be >= start mileage.
- Refueling amount supports decimal values and must be greater than 0 and no more than 100 liters.
- Recharge energy supports decimal kWh values and must be greater than 0.
- If backend rejects mileage, show field-level error.

## Acceptance Criteria

- User can add refueling, trip, service, and part records.
- Records are attached to selected vehicle.
- Records are shown in chronological timeline.
- Timeline updates after adding without app restart.
- Mileage fields are validated.
