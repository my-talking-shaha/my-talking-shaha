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
      "name": "Масло двигателя",
      "catalogKey": "engine_oil",
      "installedAt": "2026-06-08T11:00:00Z",
      "installedAtMileageKm": 123000,
      "lifetimeKm": 10000,
      "remainingKm": 7500,
      "remainingPercent": 75,
      "status": "ok"
    }
  ]
}
```

Status values:

```text
ok
warning
critical
unknown
```

## Create Part

`POST /api/v1/vehicles/{vehicleId}/parts`

Request:

```json
{
  "name": "Масло двигателя",
  "catalogKey": "engine_oil",
  "installedAt": "2026-06-08T11:00:00Z",
  "installedAtMileageKm": 123000,
  "lifetimeKm": 10000
}
```

Response `201`: created part.

## Update Part

`PATCH /api/v1/vehicles/{vehicleId}/parts/{partId}`

Request example:

```json
{
  "lifetimeKm": 12000
}
```

Response: updated part.

## Replace Part

`POST /api/v1/vehicles/{vehicleId}/parts/{partId}/replace`

Request:

```json
{
  "installedAt": "2026-07-01T10:00:00Z",
  "installedAtMileageKm": 130000,
  "lifetimeKm": 10000,
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
      "name": "Масло двигателя",
      "defaultLifetimeKm": 10000
    }
  ]
}
```

## Resource Formula

Backend should provide `remainingKm`, `remainingPercent`, and `status` when possible.

Fallback formula:

```text
remainingKm = lifetimeKm - (currentVehicleMileageKm - installedAtMileageKm)
```

If `lifetimeKm` is missing, status is `unknown` and UI displays `Ресурс не задан`.
