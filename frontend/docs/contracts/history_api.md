# History / Timeline API Contract

Base path: `/api/v1/vehicles/{vehicleId}/timeline`

Auth: required.

## Event Types

```text
TRIP
REFUEL
MAINTENANCE
PART_REPLACEMENT
```

## List Events

`GET /api/v1/vehicles/{vehicleId}/timeline?type=REFUEL`

`type` is optional. Events are returned newest first.

Response:

```json
{
  "events": [
    {
      "id": "044c10dc-13d1-4587-9169-e9e79789ea45",
      "type": "REFUEL",
      "title": "Refill AI-95",
      "eventDateTime": "2026-06-12T14:30:00Z",
      "cost": 2000,
      "mileageKm": 10000,
      "liters": 30,
      "fuelType": "GASOLINE",
      "fuelName": "AI-95",
      "stationName": "Test Station"
    }
  ]
}
```

## Add Refuel Event

`POST /api/v1/vehicles/{vehicleId}/timeline/refuel`

```json
{
  "eventDateTime": "2026-06-12T14:30:00Z",
  "mileageKm": 10000,
  "liters": 30,
  "cost": 2000,
  "fuelType": "GASOLINE",
  "fuelName": "AI-95",
  "stationName": "Test Station"
}
```

Validation: `mileageKm >= previous mileage`, `liters > 0`, `cost > 0`,
`eventDateTime <= now`.

## Add Trip Event

`POST /api/v1/vehicles/{vehicleId}/timeline/trip`

```json
{
  "eventDateTime": "2026-06-13T09:15:00Z",
  "startMileageKm": 10000,
  "endMileageKm": 10400,
  "route": "Home -> University",
  "durationMinutes": 60
}
```

Validation: `endMileageKm >= previous mileage`, `endMileageKm >= startMileageKm`,
`durationMinutes > 0`, `eventDateTime <= now`. Trip has no cost.

Trip response includes `distanceKm` and `averageFuelConsumptionLitersPerKm`.

## Add Service Event

`POST /api/v1/vehicles/{vehicleId}/timeline/maintenance`

```json
{
  "eventDateTime": "2026-06-12T16:30:00Z",
  "mileageKm": 10000,
  "name": "Oil change",
  "description": "Oil and filter replacement",
  "cost": 3000,
  "photoUrls": ["https://example.com/event-photo.jpg"]
}
```

Validation: `name` is required, `mileageKm >= previous mileage`, optional `cost > 0`,
`eventDateTime <= now`.

## Add Part Event

`POST /api/v1/vehicles/{vehicleId}/timeline/part`

```json
{
  "eventDateTime": "2026-06-14T10:00:00Z",
  "mileageKm": 10400,
  "name": "Brake pads",
  "description": "Front axle replacement",
  "cost": 4200,
  "photoUrls": ["https://example.com/brake-pads.jpg"]
}
```

Validation: `name` is required, `mileageKm >= previous mileage`, optional `cost > 0`,
`eventDateTime <= now`. Response has `type = PART_REPLACEMENT`.

## Errors

- `400 VALIDATION_ERROR`
- `401 UNAUTHORIZED` after auth is enabled
- `403 FORBIDDEN`
- `404 NOT_FOUND`
