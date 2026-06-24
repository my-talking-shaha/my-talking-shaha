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
      "status": "OK",
      "description": "Front axle",
      "cost": 2500,
      "photoUrls": []
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
  "expectedLifetimeKm": 10000,
  "description": "Shell Helix Ultra 5W-40",
  "cost": 8900,
  "photoUrls": ["https://example.com/part-photo.jpg"]
}
```

`expectedLifetimeKm`, `description`, `cost`, and `photoUrls` are optional. Response `201`:
created part.

## Update Part

`PATCH /api/v1/vehicles/{vehicleId}/parts/{partId}`

Request example:

```json
{
  "expectedLifetimeKm": 12000
}
```

Response: updated part.

## Add Part Replacement Event

Part replacement in service history is created through
`POST /api/v1/vehicles/{vehicleId}/timeline/part`.

Use it when the user enters date + time, mileage, replaced/updated part name, optional
description, optional cost, and optional photo.

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
