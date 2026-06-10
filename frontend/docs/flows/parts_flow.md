# Parts and Remaining Lifetime Flow

## User Stories

Covers:
- DATA-01 update parts and condition, Should.
- STATUS-02 remaining part lifetime, Must.

## Screens

- Parts list.
- Add part form.
- Edit part form.
- Part details.
- Replace part action.

## Parts List Flow

1. User opens `/vehicle/:vehicleId/parts` or dashboard part section.
2. Client fetches installed parts for selected vehicle.
3. Each part displays name, install date, install mileage, lifetime, remaining km/% and status.
4. Parts without lifetime display `Ресурс не задан`.

## Remaining Lifetime Formula

```text
remainingKm = initialLifetimeKm - (currentVehicleMileage - installedAtMileage)
```

Status:
- OK: remaining > 10%.
- Warning: remaining < 10% and > 0.
- Critical: remaining <= 0.
- Unknown: lifetime is not set.

Prefer backend-provided status if available. Client fallback must use this formula only for display.

## Add Part Flow

1. User taps add part.
2. User enters/selects part name.
3. User enters install date and install mileage.
4. User enters lifetime km or selects catalog item with default lifetime.
5. Client validates and submits.
6. Part appears in parts list.

## Catalog Flow

Priority: Should.

Examples:
- oil;
- oil filter;
- air filter;
- timing belt;
- brake pads.

When selected, default lifetime may be prefilled if known.

## Replace Part Flow

1. User opens part details.
2. User taps `Заменена` / replace.
3. User enters new date and mileage.
4. Backend creates replacement record and may create timeline event.
5. Parts list and timeline refresh.

## Acceptance Criteria

- Remaining resource is visible in km or percent.
- `Ресурс не задан` appears for missing lifetime.
- Warning and critical thresholds are visually clear.
- User can manually correct lifetime.
- Replace action creates/updates records according to backend contract.
