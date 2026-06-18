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
6. App navigates to `/vehicle/:vehicleId/chat`.

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
3. User enters brand, model, year, optional color, current mileage, engine type.
4. Brand/model may come from catalog or manual input.
5. Client validates fields.
6. Client sends create vehicle request.
7. On success, vehicle appears in garage.

## Edit Vehicle Flow

Edit vehicle form consists of the same fields as the add vehicle (but the fields are pre-filled with existing info)

Scenario:
1. user swipes the vehicle and taps "edit"
2. user deletes current value in the field (using the button with the cross)
3. user enters new data
4. user saves the new form
5. edit vehicle request sent
6. updated info is displayed

Acceptance criteria:
- existing values are pre-filled
- all the fields must be non-empty before saving

Exceptions:
1) Validation failed
2) Network error

## Delete Vehicle Flow

Scenario:
1) user swipes the vehicle and taps "delete"
2) confirmation dialog appears
3) user confirms deletion
4) delete vehicle request sent
5) vehicle is no longer displayed

Acceptance criteria:
- confirmation is mandatory
- garage list refreshes automatically

Exceptions:
1) Network error

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
- After choosing a vehicle, user opens the vehicle chat screen.
