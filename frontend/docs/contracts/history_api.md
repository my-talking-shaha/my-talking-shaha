# History / Timeline API Contract

Base path: `/api/v1/vehicles/{vehicleId}/events`

Auth: required.

## Event Types

```text
trip
refueling
repair
maintenance
warning
```

## List Events

`GET /api/v1/vehicles/{vehicleId}/events?type=repair&period=all&query=oil`

Response:

```json
{
  "events": [
    {
      "id": "event_123",
      "type": "refueling",
      "occurredAt": "2026-06-15T14:30:00Z",
      "mileageKm": 124580,
      "title": "Заправка АИ-95",
      "description": "45.2 литра · АЗС Газпромнефть №14",
      "cost": { "amount": 2450, "currency": "RUB" },
      "payload": {
        "liters": 45.2,
        "fuelType": "AI-95",
        "stationName": "Газпромнефть №14"
      }
    }
  ]
}
```

## Create Event

`POST /api/v1/vehicles/{vehicleId}/events`

### Repair

```json
{
  "type": "repair",
  "occurredAt": "2026-06-08T11:00:00Z",
  "mileageKm": 124000,
  "description": "Замена масла и фильтров",
  "cost": { "amount": 8900, "currency": "RUB" },
  "replacedParts": ["oil", "oil_filter"]
}
```

### Refueling

```json
{
  "type": "refueling",
  "occurredAt": "2026-06-15T14:30:00Z",
  "mileageKm": 124580,
  "liters": 45.2,
  "fuelType": "AI-95",
  "cost": { "amount": 2450, "currency": "RUB" },
  "stationName": "Газпромнефть №14"
}
```

### Trip

```json
{
  "type": "trip",
  "occurredAt": "2026-06-01T09:15:00Z",
  "startMileageKm": 124000,
  "endMileageKm": 124420,
  "route": "Москва — Тула — Москва"
}
```

### Maintenance

```json
{
  "type": "maintenance",
  "occurredAt": "2026-06-10T10:00:00Z",
  "mileageKm": 124500,
  "description": "Плановое ТО",
  "cost": { "amount": 12000, "currency": "RUB" }
}
```

Response `201`: created event.

## Update Event

`PATCH /api/v1/vehicles/{vehicleId}/events/{eventId}`

Request: same fields as create, partial allowed if backend supports it.

Response: updated event.

## Delete Event

`DELETE /api/v1/vehicles/{vehicleId}/events/{eventId}`

Response `204`.

## Validation Errors

Mileage cannot be lower than previous vehicle mileage:

```json
{
  "code": "MILEAGE_REGRESSION",
  "message": "Mileage cannot be lower than previous value",
  "details": { "field": "mileageKm" }
}
```
