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

## Add Vehicle Flow

1. User taps add button.
2. App opens add vehicle form.
3. User enters brand, model, year, current mileage, engine type.
4. Brand/model may come from catalog or manual input.
5. Client validates fields.
6. Client sends create vehicle request.
7. On success, vehicle appears in garage.

## Delete Vehicle Flow

1. User makes long tap on car card
2. Confirmation dialog appears.
3. If confirmed, client sends delete request.
4. Vehicle is removed from garage.
5. If selected vehicle was deleted, app remains in garage.

## Validation

Required:
- brand;
- model;
- year;
- current mileage;
- engine type.

Rules:
- mileage >= 0;
- year should be realistic;
- no duplicate submit.

## Acceptance Criteria

- Garage exists as a separate section.
- All user vehicles are displayed.
- User can add unlimited vehicles.
- Empty state is shown when there are no cars.
- Deletion requires confirmation.
