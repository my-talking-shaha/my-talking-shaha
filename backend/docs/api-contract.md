# API contract

API prefix: `/api/v1`

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
    "photoUrl": "https://example.com/car.jpg",
    "lastMaintenanceKmAgo": 1000,
    "lastRefuelDaysAgo": 2
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
  "vin": "TESTVIN123"
}
```

Response `201`: vehicle card.

### Get vehicle dashboard

`GET /api/v1/vehicles/{vehicleId}/dashboard`

Response `200`:

```json
{
  "vehicle": {
    "id": "096c10bb-13d1-4599-9109-e9e79789ea88",
    "brand": "Lada",
    "model": "2106",
    "displayName": "Test Car",
    "mileageKm": 10000,
    "fuelType": "GASOLINE",
    "engineDescription": "1.6 L",
    "vin": "TESTVIN123",
    "photoUrl": "https://example.com/car.jpg"
  },
  "maintenanceForecast": {
    "overallStatus": "ATTENTION",
    "nextServiceInKm": 500,
    "estimatedDate": "2026-07-01",
    "updatedAt": "2026-06-12T10:00:00Z",
    "parts": [
      {
        "id": "023c10cc-13d1-4567-9109-e9e79789ea21",
        "name": "Brake pads",
        "remainingKm": 500,
        "remainingPercent": 8,
        "status": "ATTENTION"
      }
    ]
  },
  "recentEvents": [
    {
      "id": "044c10dc-13d1-4587-9169-e9e79789ea45",
      "type": "TRIP",
      "title": "Trip completed",
      "subtitle": "Home -> University, 10 km",
      "eventDateTime": "2026-06-12T14:20:00Z"
    }
  ]
}
```

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

### List timeline

`GET /api/v1/vehicles/{vehicleId}/timeline?type=REFUEL&page=0&size=20`

`type` is optional. Supported values: `TRIP`, `REFUEL`, `REPAIR`, `MAINTENANCE`, `PART_REPLACEMENT`, `WARNING`.

Response `200`:

```json
{
  "items": [
    {
      "id": "044c10dc-13d1-4587-9169-e9e79789ea45",
      "type": "REFUEL",
      "eventDateTime": "2026-06-12T14:30:00Z",
      "mileageKm": 10000,
      "title": "Fuel refill",
      "description": "30 liters of AI-95 fuel",
      "cost": 2000,
      "currency": "RUB",
      "photoUrls": []
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1
}
```

### Add refuel

`POST /api/v1/vehicles/{vehicleId}/timeline/refuels`

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

Response `201`: timeline event.

### Add repair or maintenance

`POST /api/v1/vehicles/{vehicleId}/timeline/repairs`

Request:

```json
{
  "type": "MAINTENANCE",
  "eventDateTime": "2026-06-12T16:30:00Z",
  "mileageKm": 10000,
  "description": "Oil and filter replacement",
  "cost": 3000,
  "replacedParts": [
    {
      "name": "Engine oil",
      "expectedLifetimeKm": 8000
    }
  ],
  "photoUrls": [
    "https://example.com/event-photo.jpg"
  ]
}
```

Response `201`: timeline event.

### Add trip

`POST /api/v1/vehicles/{vehicleId}/timeline/trips`

Request:

```json
{
  "eventDateTime": "2026-06-12T09:15:00Z",
  "startMileageKm": 10000,
  "endMileageKm": 10010,
  "route": "Home -> University",
  "durationMinutes": 30,
  "cost": 0
}
```

Response `201`: timeline event.

### Update timeline event

`PATCH /api/v1/vehicles/{vehicleId}/timeline/{eventId}`

### Delete timeline event

`DELETE /api/v1/vehicles/{vehicleId}/timeline/{eventId}`

Response `204`.

## Parts

### List vehicle parts

`GET /api/v1/vehicles/{vehicleId}/parts`

Response `200`:

```json
[
  {
    "id": "044c10cc-13d1-4587-9168-e9e79789ea67",
    "name": "Engine oil",
    "category": "ENGINE_OIL",
    "installedAt": "2026-06-12",
    "installedMileageKm": 10000,
    "expectedLifetimeKm": 8000,
    "remainingKm": 8000,
    "remainingPercent": 100,
    "status": "OK"
  }
]
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
  "photoUrl": null
}
```

Response `201`: part.

### Replace part

`POST /api/v1/vehicles/{vehicleId}/parts/{partId}/replace`

Request:

```json
{
  "installedAt": "2026-06-12",
  "installedMileageKm": 10000,
  "expectedLifetimeKm": 25000,
  "cost": 2500,
  "description": "Front brake pad replacement"
}
```

Response `201`: new part plus created timeline event.

## Analytics

### Get analytics summary

`GET /api/v1/vehicles/{vehicleId}/analytics?period=YEAR&year=2026`

Response `200`:

```json
{
  "period": "YEAR",
  "totalExpenses": 5000,
  "currency": "RUB",
  "expensesByCategory": {
    "REPAIR": 2500,
    "FUEL": 2000,
    "MAINTENANCE": 500,
    "PARTS": 0
  },
  "costPerKm": 5,
  "monthlyExpenses": [
    {
      "month": "2026-06",
      "amount": 5000
    }
  ],
  "failureFrequency": [
    {
      "month": "2026-06",
      "count": 1
    }
  ],
  "frequentRepairs": [
    {
      "name": "Brakes",
      "count": 1
    }
  ],
  "mileageDynamics": {
    "kmPerMonth": 1000,
    "trendPercent": 10
  }
}
```

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