# History / Timeline API Contract

Base path: `/api/v1/vehicles/{vehicleId}/timeline`

Auth: required.

## Event Types

```text
TRIP
REFUEL
RECHARGE
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
      "title": "Refuel",
      "eventDateTime": "2026-06-12T14:30:00Z",
      "cost": 2000,
      "mileageKm": 10000,
      "liters": 30,
      "fuelType": "GASOLINE",
      "fuelName": "95 octane",
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
  "fuelName": "95 octane",
  "stationName": "Test Station"
}
```

Validation: `mileageKm >= previous mileage`, `liters > 0`, `cost > 0`,
`eventDateTime <= now`.

Electric refuel payloads may be returned as `type = RECHARGE` for backwards
compatibility, but the client should use the dedicated recharge endpoint for
electric vehicles.

## Add Recharge Event

`POST /api/v1/vehicles/{vehicleId}/timeline/recharge`

```json
{
  "eventDateTime": "2026-06-12T14:30:00Z",
  "title": "Recharge",
  "mileageKm": 10000,
  "kwh": 37.5,
  "cost": 1200,
  "fuelType": "ELECTRIC",
  "fuelName": "AC charging",
  "stationName": "Home charger"
}
```

The created event has `type = RECHARGE`. Recharge responses include `kwh` and
may also include legacy `liters` with the same value for current mobile
compatibility.

Validation: `mileageKm >= previous mileage`, `kwh > 0`, `cost > 0`,
`fuelType = ELECTRIC`, `eventDateTime <= now`.

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

Content-Type: `multipart/form-data` with:

- one `event` part using `application/json`;
- zero or more `photos` parts containing JPG/PNG files.

The `event` part:

```json
{
  "eventDateTime": "2026-06-12T16:30:00Z",
  "mileageKm": 10000,
  "name": "Oil change",
  "description": "Oil and filter replacement",
  "cost": 3000
}
```

Response `201` contains the created timeline event. Its `photoUrls` field holds
absolute backend URLs for the stored photos. Invalid or unsupported files return
`400 VALIDATION_ERROR`.

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

## Update Event

`PATCH /api/v1/vehicles/{vehicleId}/timeline/{eventId}`

Request body uses the same event-specific fields as add endpoints:

- refuel: `eventDateTime`, `mileageKm`, `liters`, `cost`, `fuelType`, optional
  `fuelName`, optional `stationName`;
- recharge: `eventDateTime`, `mileageKm`, `kwh`, `cost`, `fuelType = ELECTRIC`,
  optional `fuelName`, optional `stationName`;
- trip: `eventDateTime`, `startMileageKm`, `endMileageKm`, optional `route`,
  `durationMinutes`;
- maintenance/part: `eventDateTime`, `mileageKm`, `name`, `description`,
  optional `cost`. Photo attachments are not changed by this endpoint.

Validation is the same as the matching add event endpoint. Event type is not
changed by this endpoint.

## Delete Event

`DELETE /api/v1/vehicles/{vehicleId}/timeline/{eventId}`

Response: empty body or success envelope. Deleting a maintenance event also
deletes its stored backend photo attachments; after success, the client clears
the matching local photo cache.

## Errors

- `400 VALIDATION_ERROR`
- `401 UNAUTHORIZED` after auth is enabled
- `403 FORBIDDEN`
- `404 NOT_FOUND`
