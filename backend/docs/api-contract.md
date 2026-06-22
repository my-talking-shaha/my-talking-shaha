# API contract

API prefix: `/api/v1`

> Status: the Garage/Vehicles, Parts, Timeline, and Analytics sections are implemented. Auth,
> Chat, Prediction, and Notifications are planned and described here as the
> target contract. The machine-readable spec in `openapi.yaml` covers the implemented
> endpoints only.

## Common rules

Headers:

```http
Content-Type: application/json
Authorization: Bearer <accessToken>
```

Pagination query:

```text
?page=0&size=20
```

Common error:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Request contains invalid fields",
  "fields": {
    "password": "Password must contain at least 6 characters"
  }
}
```

## Auth

### Register

`POST /api/v1/auth/register`

Request:

```json
{
  "email": "test@example.com",
  "password": "test123",
  "displayName": "Test User"
}
```

Response `201`:

```json
{
  "accessToken": "test-token",
  "user": {
    "id": "045c10aa-13d1-4599-9109-e9e79789ea91",
    "email": "test@example.com",
    "displayName": "Test User"
  }
}
```

Errors:

- `400 VALIDATION_ERROR`
- `409 CONFLICT` if email already exists

### Login

`POST /api/v1/auth/login`

Request:

```json
{
  "email": "test@example.com",
  "password": "test123"
}
```

Response `200`: same as register.

### Current user

`GET /api/v1/users/me`

Response `200`:

```json
{
  "id": "045c10aa-13d1-4599-9109-e9e79789ea91",
  "email": "test@example.com",
  "displayName": "Test User"
}
```

## Garage and vehicles

### List garage vehicles

`GET /api/v1/vehicles`

Response `200`:

```json
[
  {
    "id": "096c10bb-13d1-4599-9109-e9e79789ea88",
    "brand": "Lada",
    "model": "2106",
    "productionYear": 2002,
    "color": "green",
    "mileageKm": 10000,
    "fuelType": "GASOLINE",
    "engineDescription": "1.6 L",
    "vin": "XTA21060012345678",
    "photoUrl": "https://example.com/car.jpg"
  }
]
```

### Create vehicle

`POST /api/v1/vehicles`

Request:

```json
{
  "brand": "Lada",
  "model": "2106",
  "productionYear": 2002,
  "color": "green",
  "mileageKm": 10000,
  "fuelType": "GASOLINE",
  "engineDescription": "1.6 L",
  "vin": "XTA21060012345678"
}
```

Response `201`: vehicle card.

Validation:

- `brand`, `model`, `productionYear`, `mileageKm`, and `fuelType` are required;
- `productionYear >= 1900`;
- `productionYear <= current year`;
- `mileageKm >= 0`;
- `vin` is optional, but must contain exactly 17 symbols when provided.

### Get vehicle dashboard

`GET /api/v1/vehicles/{vehicleId}/dashboard`

Response `200`:

```json
{
  "vehicle": {
    "id": "096c10bb-13d1-4599-9109-e9e79789ea88",
    "brand": "Lada",
    "model": "2106",
    "productionYear": 2002,
    "color": "green",
    "mileageKm": 10000,
    "fuelType": "GASOLINE",
    "engineDescription": "1.6 L",
    "vin": "XTA21060012345678",
    "photoUrl": "https://example.com/car.jpg"
  },
  "maintenanceForecast": {
    "overallStatus": "ATTENTION",
    "nextServiceInKm": 500,
    "updatedAt": "2026-06-12T10:00:00Z",
    "parts": [
      {
        "id": "023c10cc-13d1-4567-9109-e9e79789ea21",
        "name": "Brake pads",
        "category": "BRAKE_PADS",
        "installedAt": "2026-06-12",
        "installedMileageKm": 10000,
        "expectedLifetimeKm": 25000,
        "remainingKm": 500,
        "remainingPercent": 8,
        "status": "ATTENTION"
      }
    ]
  },
  "recentEvents": [
    {
      "id": "044c10dc-13d1-4587-9169-e9e79789ea45",
      "type": "REFUEL",
      "title": "Refill AI-95",
      "subtitle": "30 L",
      "eventDateTime": "2026-06-12T14:30:00Z"
    }
  ]
}
```

`recentEvents` contains up to five of the most recent timeline events, newest first, in a
compact form (`id`, `type`, `title`, `subtitle`, `eventDateTime`).

### Update vehicle

`PATCH /api/v1/vehicles/{vehicleId}`

Request can contain any editable fields:

```json
{
  "color": "blue",
  "mileageKm": 10500,
  "photoUrl": "https://example.com/new-car.jpg"
}
```

### Delete vehicle

`DELETE /api/v1/vehicles/{vehicleId}`

Response `204`.

## Timeline

Every event is returned in a single unified shape. Only the fields relevant to the
event `type` are populated; the rest are `null`.

### List events

`GET /api/v1/vehicles/{vehicleId}/timeline?type=REFUEL`

`type` is optional. Supported values: `TRIP`, `REFUEL`, `REPAIR`, `MAINTENANCE`,
`PART_REPLACEMENT`, `WARNING`. Events are returned most recent first. Pagination is not
implemented yet.

Response `200`:

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

### Add refuel

`POST /api/v1/vehicles/{vehicleId}/timeline/refuel`

Request:

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

Response `201`: timeline event. `liters > 0` and `cost > 0`.

### Add trip

`POST /api/v1/vehicles/{vehicleId}/timeline/trip`

Request:

```json
{
  "eventDateTime": "2026-06-12T09:15:00Z",
  "startMileageKm": 10000,
  "endMileageKm": 10010,
  "route": "Home -> University",
  "durationMinutes": 30
}
```

`startMileageKm` is optional; when present it must not exceed `endMileageKm`. Trips have no
cost. Response `201`: timeline event.

### Add maintenance

`POST /api/v1/vehicles/{vehicleId}/timeline/maintenance`

Request:

```json
{
  "eventDateTime": "2026-06-12T16:30:00Z",
  "mileageKm": 10000,
  "name": "Oil change",
  "description": "Oil and filter replacement",
  "cost": 3000,
  "photoUrls": [
    "https://example.com/event-photo.jpg"
  ]
}
```

`cost`, when provided, must be greater than `0`. Response `201`: timeline event.

### Add part event

`POST /api/v1/vehicles/{vehicleId}/timeline/part`

Request:

```json
{
  "eventDateTime": "2026-06-14T10:00:00Z",
  "mileageKm": 10400,
  "name": "Brake pads",
  "description": "Front axle replacement",
  "cost": 4200,
  "photoUrls": [
    "https://example.com/brake-pads.jpg"
  ]
}
```

`name`, `eventDateTime`, and `mileageKm` are required. `description`, `cost`, and
`photoUrls` are optional. `cost`, when provided, must be greater than `0`.
Response `201`: timeline event with `type = PART_REPLACEMENT`.

Creating any event with a `mileageKm`/`endMileageKm` higher than the vehicle's current
mileage advances the vehicle mileage and recalculates its parts.

## Parts

### List vehicle parts

`GET /api/v1/vehicles/{vehicleId}/parts`

Response `200`:

```json
{
  "parts": [
    {
      "id": "044c10cc-13d1-4587-9168-e9e79789ea67",
      "name": "Engine oil",
      "category": "ENGINE_OIL",
      "installedAt": "2026-06-12",
      "installedMileageKm": 10000,
      "expectedLifetimeKm": 8000,
      "remainingKm": 8000,
      "remainingPercent": 100,
      "status": "OK",
      "description": "Front axle",
      "cost": 2500,
      "photoUrls": []
    }
  ]
}
```

### Create part

`POST /api/v1/vehicles/{vehicleId}/parts`

Request:

```json
{
  "name": "Brake pads",
  "category": "BRAKE_PADS",
  "installedAt": "2026-06-12",
  "installedMileageKm": 10000,
  "expectedLifetimeKm": 25000,
  "description": "Front axle",
  "cost": 2500,
  "photoUrls": [
    "https://example.com/part-photo.jpg"
  ]
}
```

`expectedLifetimeKm` is optional; when omitted, a per-category default is used.
`description`, `cost`, and `photoUrls` are optional. Response `201`: part.

### Update part

`PATCH /api/v1/vehicles/{vehicleId}/parts/{partId}`

Request can contain any editable part fields:

```json
{
  "expectedLifetimeKm": 30000
}
```

Response `200`: updated part with recalculated `remainingKm`, `remainingPercent`, and `status`.

Part replacements are represented in service history by
`POST /api/v1/vehicles/{vehicleId}/timeline/part`.

## Analytics

### Get analytics overview

`GET /api/v1/vehicles/{vehicleId}/analytics?period=YEAR`

`period` is optional. Supported values: `MONTH`, `YEAR`, `ALL_TIME`.

Response `200`:

```json
{
  "period": "YEAR",
  "totalExpenses": 342500,
  "currency": "RUB",
  "expensesByCategory": {
    "FUEL": 112500,
    "MAINTENANCE": 56000,
    "PARTS": 174000
  },
  "monthlyExpenses": [
    {
      "month": "2026-06",
      "total": 15650,
      "breakdownByCategory": {
        "FUEL": 2450,
        "MAINTENANCE": 8900,
        "PARTS": 4300
      }
    }
  ],
  "seasonalExpenses": [
    {
      "season": "SUMMER",
      "total": 15650
    }
  ],
  "costPerKilometer": {
    "totalKm": 1240,
    "totalExpenses": 15650,
    "costPerKm": 12.62
  },
  "fuel": {
    "totalLiters": 120.4,
    "averageConsumptionLitersPer100Km": 7.2
  },
  "historyAnalysis": {
    "eventCount": 7,
    "refuelCount": 2,
    "tripCount": 1,
    "maintenanceCount": 3,
    "partEventCount": 1,
    "totalTripKm": 1240,
    "averageTripKm": 1240
  },
  "hasData": true
}
```

If there is no data for the selected period, response is still `200` with zero totals,
empty chart arrays, zero metrics, and `hasData = false`.

## Chat

### Get chat state

`GET /api/v1/vehicles/{vehicleId}/chat`

Response `200`:

```json
{
  "sessionId": "034c13vc-13d2-4557-9169-e9e79789ea49",
  "quickQuestions": [
    "When should I change the oil?",
    "What is the current mileage?",
    "What can break soon?"
  ],
  "messages": [
    {
      "id": "125c13vj-13d2-4557-9149-e9e79789ea83",
      "role": "ASSISTANT",
      "text": "The assistant is ready.",
      "createdAt": "2026-06-12T10:00:00Z"
    }
  ]
}
```

### Send message

`POST /api/v1/vehicles/{vehicleId}/chat/messages`

Request:

```json
{
  "text": "I changed the oil at 10000 km"
}
```

Response `200`:

```json
{
  "userMessage": {
    "id": "533c17vc-13d5-6857-5269-e9e80739ea42",
    "role": "USER",
    "text": "I changed the oil at 10000 km",
    "createdAt": "2026-06-12T10:00:00Z"
  },
  "assistantMessage": {
    "id": "784v15jc-15d3-4957-9189-u8e79789ea66",
    "role": "ASSISTANT",
    "text": "Do you want to add a part replacement record?",
    "createdAt": "2026-06-12T10:00:01Z",
    "action": {
      "type": "OPEN_FORM",
      "form": "PART_REPLACEMENT",
      "prefill": {
        "partName": "Engine oil",
        "mileageKm": 10000
      }
    }
  }
}
```

If there is not enough data:

```json
{
  "assistantMessage": {
    "role": "ASSISTANT",
    "text": "There is not enough data to answer.",
    "metadata": {
      "reason": "NO_TRIPS_FOR_PERIOD"
    }
  }
}
```

## Prediction

### Get maintenance forecast

`GET /api/v1/vehicles/{vehicleId}/prediction/maintenance`

Response `200`:

```json
{
  "overallStatus": "ATTENTION",
  "nextServiceInKm": 500,
  "updatedAt": "2026-06-12T10:00:00Z",
  "parts": [
    {
      "partId": "091f14fc-83d2-4157-9566-j2e63789ea84",
      "name": "Brake pads",
      "remainingKm": 500,
      "remainingPercent": 8,
      "status": "ATTENTION",
      "recommendation": "Plan a brake pad inspection."
    }
  ]
}
```

## Notifications

### List notifications

`GET /api/v1/notifications?page=0&size=20`

Response `200`:

```json
{
  "items": [
    {
      "id": "306w17hc-23o2-8597-6390-l9u83789ea47",
      "vehicleId": "096c10bb-13d1-4599-9109-e9e79789ea88",
      "title": "Brake pads need attention",
      "message": "About 500 km of lifetime remains.",
      "severity": "WARNING",
      "read": false,
      "createdAt": "2026-06-12T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1
}
```