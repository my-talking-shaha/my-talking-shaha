# Parts API Contract

Base path: `/api/v1/vehicles/{vehicleId}/parts`

Auth: required.

## List Parts

`GET /api/v1/vehicles/{vehicleId}/parts`

Response:

```json
{
  "parts": [
    {
      "id": "part_123",
      "name": "Engine oil",
      "category": "ENGINE_OIL",
      "installedAt": "2026-06-08",
      "installedMileageKm": 123000,
      "expectedLifetimeKm": 10000,
      "remainingKm": 7500,
      "remainingPercent": 75,
      "status": "OK"
    }
  ]
}
```

Status values:

```text
OK
ATTENTION
CRITICAL
UNKNOWN
```

## Create Part

`POST /api/v1/vehicles/{vehicleId}/parts`

Request:

```json
{
  "name": "Engine oil",
  "category": "ENGINE_OIL",
  "installedAt": "2026-06-08",
  "installedMileageKm": 123000,
  "expectedLifetimeKm": 10000
}
```

Response `201`: created part.

## Update Part

`PATCH /api/v1/vehicles/{vehicleId}/parts/{partId}`

Request example:

```json
{
  "expectedLifetimeKm": 12000
}
```

Response: updated part.

## Replace Part

`POST /api/v1/vehicles/{vehicleId}/parts/{partId}/replace`

Request:

```json
{
  "installedAt": "2026-07-01",
  "installedMileageKm": 130000,
  "expectedLifetimeKm": 10000,
  "createTimelineEvent": true
}
```

Response:

```json
{
  "part": { "id": "part_456" },
  "createdEventId": "event_789"
}
```

## Catalog

`GET /api/v1/parts/catalog`

Response:

```json
{
  "items": [
    {
      "key": "engine_oil",
      "name": "Engine oil",
      "defaultLifetimeKm": 10000
    }
  ]
}
```

## Resource Formula

Backend should provide `remainingKm`, `remainingPercent`, and `status` when possible.

Fallback formula:

```text
remainingKm = expectedLifetimeKm - (currentVehicleMileageKm - installedMileageKm)
```

If `expectedLifetimeKm` is missing, status is `UNKNOWN`.
