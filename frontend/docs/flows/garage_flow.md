# Garage Flow

## User Stories

Covers:
- ACC-03 Add multiple vehicles.
- ACC-04 Garage list.

## Screens

- Garage list screen.
- Empty garage screen.
- Add vehicle form.
- Delete confirmation dialog.

## Garage List Flow

1. Authenticated user opens `/garage`.
2. Client fetches user's vehicles.
3. If list is empty, show empty state with `Добавить автомобиль` action.
4. If list has cars, show vehicle cards.
5. User taps a vehicle card.
6. App navigates to `/vehicle/:vehicleId`.

## Vehicle Card Content

Each card should display:
- brand;
- model;
- year;
- color if available;
- photo if available;
- engine type;
- current mileage;
- status summary when available.

## Add Vehicle Flow

1. User taps plus/add button.
2. App opens add vehicle form.
3. User enters brand, model, year, color, current mileage, engine type.
4. Brand/model may come from catalog or manual input.
5. Client validates fields.
6. Client sends create vehicle request.
7. On success, vehicle appears in garage.

## Delete Vehicle Flow

1. User opens vehicle actions.
2. User taps delete.
3. Confirmation dialog appears.
4. If confirmed, client sends delete request.
5. Vehicle is removed from garage.
6. If selected vehicle was deleted, app remains/returns to garage.

## Validation

Required:
- brand;
- model;
- year;
- current mileage;
- engine type.

Optional:
- color.

Rules:
- mileage >= 0;
- year should be realistic;
- no duplicate submit.

## Acceptance Criteria

- Garage exists as a separate section.
- All user vehicles are displayed.
- User can add unlimited vehicles.
- User can open vehicle details.
- Empty state is shown when there are no cars.
- Deletion requires confirmation.
