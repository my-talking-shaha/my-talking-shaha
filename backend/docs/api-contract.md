# API contract

API prefix: `/api/v1`

> Status: the Auth, Garage/Vehicles, Parts, Timeline, and Analytics sections are implemented.
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
    "password": "Password must be between 6 and 72 characters"
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
  "user": {
    "id": "045c10aa-13d1-4599-9109-e9e79789ea91",
    "email": "test@example.com",
    "displayName": "Test User"
  },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

Password rules: 6-72 characters; letters (a-z, A-Z), digits, and `()[]$#*-_?!.%+<>/`.

Errors:

- `400 VALIDATION_ERROR`
- `409 EMAIL_ALREADY_EXISTS` if email already exists

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

Errors:

- `401 INVALID_CREDENTIALS`

### Refresh

`POST /api/v1/auth/refresh`

Request:

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

Response `200`:

```json
{
  "accessToken": "new-access-token",
  "refreshToken": "new-refresh-token"
}
```

The presented refresh token is rotated out (single use).

Errors:

- `401 INVALID_CREDENTIALS` if the refresh token is invalid or expired

### Logout

`POST /api/v1/auth/logout`

Request:

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

Response `204`.

### Current user

`GET /api/v1/users/me`

Returns the profile of the authenticated user. Requires a valid access token.

Response `200`:

```json
{
  "id": "045c10aa-13d1-4599-9109-e9e79789ea91",
  "email": "test@example.com",
  "displayName": "Test User"
}
```

Errors:

- `401 AUTHENTICATION_REQUIRED` if the access token is missing or invalid
- `404 NOT_FOUND` if the authenticated user no longer exists
Client usage:

- The profile/settings header should use this response for signed-in user identity.
- Profile editing is outside the current MVP contract unless a dedicated account endpoint is added.
- Vehicle profile data belongs to the vehicle/dashboard endpoints, not `/users/me`.

## Garage and vehicles

### List vehicle brands

`GET /api/v1/vehicles/brands`

Returns all supported car brand names sorted alphabetically. Requires authentication.

Response `200`:

```json
[
  "Abarth",
  "BMW"
]
```

### List fuel types

`GET /api/v1/vehicles/fuel-types`

Returns the fuel type options for selection lists. Requires authentication. `code` is the
value submitted back as `fuelType`; `label` is the text shown to the user.

Response `200`:

```json
[
  { "code": "PETROL_92", "label": "Petrol (92)" },
  { "code": "PETROL_95", "label": "Petrol (95)" },
  { "code": "PETROL_98", "label": "Petrol (98)" },
  { "code": "PETROL_100", "label": "Petrol (100)" },
  { "code": "DIESEL", "label": "Diesel" }
]
```

### List engine types

`GET /api/v1/vehicles/engine-types`

Returns the engine type options for selection lists. Requires authentication. `code` is the
value submitted back as `fuelType`; `label` is the text shown to the user.

Response `200`:

```json
[
  { "code": "GASOLINE", "label": "Gasoline" },
  { "code": "DIESEL", "label": "Diesel" },
  { "code": "HYBRID", "label": "Hybrid" },
  { "code": "PHEV", "label": "PHEV" },
  { "code": "ELECTRIC", "label": "Electric" }
]
```

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

Supported `fuelType` values (also used by refuel timeline events):

```text
PETROL_92, PETROL_95, PETROL_98, PETROL_100, DIESEL, ELECTRIC, HYBRID, PHEV,
GASOLINE, OTHER
```
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
      "title": "Заправка",
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
  "mileageKm": 10500
}
```

`photoUrl` is read-only and managed through the photo endpoints below.

### Delete vehicle

`DELETE /api/v1/vehicles/{vehicleId}`

Response `204`. Also deletes the vehicle's parts, timeline events, chat history, and photos.

### Upload vehicle photo

`POST /api/v1/vehicles/{vehicleId}/photos`

Content-Type: `multipart/form-data` with a single `file` field containing a JPG or PNG image.
The declared content type must match the actual file content; maximum size is 10 MB.

Response `201`:

```json
{
  "photoId": "3f2a6c1e-8b4d-4c2a-9f1e-5d7b8a9c0d1f",
  "url": "https://example.com/api/v1/photos/3f2a6c1e-8b4d-4c2a-9f1e-5d7b8a9c0d1f"
}
```

Errors:

- `400 VALIDATION_ERROR` if the file is empty, not a JPG/PNG image, or exceeds the size limit

### List vehicle photos

`GET /api/v1/vehicles/{vehicleId}/photos`

Response `200` (ordered by upload time, oldest first):

```json
{
  "photos": [
    {
      "photoId": "3f2a6c1e-8b4d-4c2a-9f1e-5d7b8a9c0d1f",
      "url": "https://example.com/api/v1/photos/3f2a6c1e-8b4d-4c2a-9f1e-5d7b8a9c0d1f"
    }
  ]
}
```

### Delete vehicle photo

`DELETE /api/v1/vehicles/{vehicleId}/photos/{photoId}`

Response `204`. Replacing a photo is a delete followed by an upload.

### Get photo content

`GET /api/v1/photos/{photoId}`

Serves the photo bytes with the stored content type. This endpoint requires no
authentication because client image widgets cannot attach the JWT header; access
protection relies on the unguessable random photo id in the URL.

The first uploaded photo is exposed as `photoUrl` in vehicle responses (garage list
and dashboard); vehicles without photos have `photoUrl = null`.

## Timeline

Every event is returned in a single unified shape. Only the fields relevant to the
event `type` are populated; the rest are `null`.

### List events

`GET /api/v1/vehicles/{vehicleId}/timeline?type=REFUEL`

`type` is optional. Supported values: `TRIP`, `REFUEL`, `RECHARGE`, `REPAIR`, `MAINTENANCE`,
`PART_REPLACEMENT`, `WARNING`. Events are returned most recent first. Pagination is not
implemented yet.

Response `200`:

```json
{
  "events": [
    {
      "id": "044c10dc-13d1-4587-9169-e9e79789ea45",
      "type": "REFUEL",
      "title": "Заправка",
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
  "fuelName": "95 octane",
  "stationName": "Test Station"
}
```

Response `201`: timeline event. `liters > 0` and `cost > 0`.

### Add recharge

`POST /api/v1/vehicles/{vehicleId}/timeline/recharge`

Request uses the same payload shape as refuel. The created event has `type = RECHARGE`
and must use `fuelType = ELECTRIC`. Use `kwh` for the charged energy amount. For backwards
compatibility with the current mobile client, `liters` is still accepted as a legacy alias
for `kwh`, and recharge responses include both `kwh` and `liters` with the same value.
Posting the same electric payload to `/timeline/refuel` also creates a `RECHARGE` event.

```json
{
  "eventDateTime": "2026-06-12T14:30:00Z",
  "mileageKm": 10000,
  "kwh": 37.5,
  "cost": 1200,
  "fuelType": "ELECTRIC",
  "fuelName": "AC charging",
  "stationName": "Home charger"
}
```

Response `201`: timeline event. `0 < kwh <= 500` and `0 < cost <= 100000`.

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

### Update event

`PATCH /api/v1/vehicles/{vehicleId}/timeline/{eventId}`

Request body uses the same event-specific fields as the matching add endpoint:

- refuel: `eventDateTime`, `mileageKm`, `liters`, `cost`, `fuelType`, optional
  `fuelName`, optional `stationName`;
- recharge: `eventDateTime`, `mileageKm`, `kwh`, `cost`, `fuelType = ELECTRIC`, optional
  `fuelName`, optional `stationName`. `liters` is accepted as a legacy alias for `kwh`;
- trip: `eventDateTime`, `endMileageKm`, `durationMinutes`, optional
  `startMileageKm`, optional `route`;
- maintenance/part: `eventDateTime`, `mileageKm`, `name`, optional `description`,
  optional `cost`, optional `photoUrls`.

Field validation is the same as the matching add endpoint. The event type is
determined by the stored event and is not changed by this endpoint.

Response `200`: the updated timeline event in the same shape as list/create
responses.

Updating an event with a `mileageKm`/`endMileageKm` higher than the vehicle's
current mileage advances the vehicle mileage and recalculates its parts. The
vehicle mileage is never lowered automatically.

### Delete event

`DELETE /api/v1/vehicles/{vehicleId}/timeline/{eventId}`

Response `204` with empty body. Deleting an event does not change the vehicle's
current mileage.

Both endpoints return `404 NOT_FOUND` when the event does not exist or belongs
to another vehicle, and `403 FORBIDDEN` when the vehicle belongs to another
user.

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

Custom date ranges are supported with inclusive ISO dates:

`GET /api/v1/vehicles/{vehicleId}/analytics?startDate=2026-01-01&endDate=2026-06-30`

`startDate` and `endDate` must be provided together. When both are present,
the custom interval takes precedence over `period`.

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

### Get mileage trend

`GET /api/v1/vehicles/{vehicleId}/analytics/mileage-trend?year=2026&month=6`

`year` is required. `month` is optional and must be a number from `1` to `12`.
When `month` is omitted, the backend returns a yearly mileage trend grouped by
month. When `month` is provided, the backend returns points inside that calendar
month. Values are accumulated odometer mileage in kilometers and are ready for
line chart rendering.

Response `200`:

```json
{
  "year": 2026,
  "month": 6,
  "points": [
    {
      "label": "Jun 1",
      "mileageKm": 142000
    },
    {
      "label": "Jun 15",
      "mileageKm": 143240
    },
    {
      "label": "Jun 30",
      "mileageKm": 145180
    }
  ],
  "hasData": true
}
```

If `month` is omitted, `month` is returned as `null` or omitted and `points`
should use month labels such as `Jan`, `Feb`, `Mar`.

If there is no mileage data for the selected filter, response is still `200`
with `points = []` and `hasData = false`.

## Chat

### Get chat state

`GET /api/v1/vehicles/{vehicleId}/chat?language=EN`

`language` is optional (`EN` or `RU`) and controls the initial assistant message plus
fallback quick questions before any user messages exist.

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
      "text": "Hi! I am your car, and I am ready to chat.",
      "createdAt": "2026-06-12T10:00:00Z"
    }
  ]
}
```

### Get chat history

`GET /api/v1/vehicles/{vehicleId}/chat/messages?language=EN`

Response `200`:

```json
{
  "messages": [
    {
      "id": "125c13vj-13d2-4557-9149-e9e79789ea83",
      "role": "ASSISTANT",
      "text": "Hi! I am your car, and I am ready to chat.",
      "createdAt": "2026-06-12T10:00:00Z"
    }
  ]
}
```

### Send message

`POST /api/v1/vehicles/{vehicleId}/chat/messages`

Trip lifecycle intents are supported directly in this chat endpoint. A natural-language
message such as "I want to start a trip now" creates an in-progress trip and returns it
as `createdEvent`. Follow-up trip details sent to the same chat session update that trip
until it becomes `COMPLETE` or remains saved as `PARTIAL`.

Request:

```json
{
  "text": "I changed the oil at 10000 km"
}
```

Response `201`:

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
      "screen": null,
      "prefill": {
        "partName": "Engine oil",
        "mileageKm": 10000
      }
    }
  },
  "createdEvent": null
}
```

For screen redirects, the assistant message uses:

When the raw text contains enough validated data for a supported event, the same endpoint
creates the timeline event immediately and returns a confirmation assistant message with
an `OPEN_SCREEN` action pointing to `HISTORY_EVENT_EDIT` and `createdEvent` filled with
the created timeline event. The action `prefill` contains at least `eventId` and
`eventType`, so the client can suggest opening the edit screen for this exact event.
Supported automatic event creation currently covers refuel, trip, and
maintenance/repair messages. If required fields are missing or validation fails, the car
asks for the missing or corrected values in chat, keeps a pending draft, and returns an
`OPEN_FORM` action with the extracted fields in `prefill`.

Example:

```json
{
  "text": "I refueled 95 octane gas for 5 liters for 1000 rubles"
}
```

Response `201`:

```json
{
  "assistantMessage": {
    "role": "ASSISTANT",
    "text": "I recorded my refuel: 5 L 95 octane, 1000 RUB. My mileage is now 10000 km.",
    "action": {
      "type": "OPEN_SCREEN",
      "form": null,
      "screen": "HISTORY_EVENT_EDIT",
      "prefill": {
        "eventId": "994v15jc-15d3-4957-9189-u8e79789ea66",
        "eventType": "REFUEL"
      }
    }
  },
  "createdEvent": {
    "id": "994v15jc-15d3-4957-9189-u8e79789ea66",
    "type": "REFUEL",
    "mileageKm": 10000,
    "liters": 5,
    "cost": 1000,
    "fuelType": "GASOLINE",
    "fuelName": "95 octane"
  }
}
```

If required fields are missing, the car asks the user to send the missing values in chat.
For example, `I filled the car with 5 liters of 95 octane.` creates a pending refuel
draft, asks for the cost, and returns `OPEN_FORM` with the extracted refuel fields in
`prefill`; a follow-up like `for 1000 rubles` completes validation and creates the
`REFUEL` timeline event.

For chat-created refuel records, `fuelName` must match one of the currently supported
frontend values: `92 octane`, `95 octane`, `98 octane`, `100 octane`, or `Diesel`.

Generic repair intent such as `I want to record the repair` must not create a maintenance
event by itself. The backend asks for the repair/work description and validates mileage
and optional cost before creating the record.

```json
{
  "action": {
    "type": "OPEN_SCREEN",
    "form": null,
    "screen": "ANALYTICS",
    "prefill": {}
  }
}
```

Supported `screen` values are `ANALYTICS`, `MAINTENANCE_FORECAST`, `DASHBOARD`, and
`HISTORY_EVENT_EDIT`. `HISTORY_EVENT_EDIT` requires `prefill.eventId` and
`prefill.eventType`.

If there is not enough data:

```json
{
  "userMessage": {
    "id": "533c17vc-13d5-6857-5269-e9e80739ea42",
    "role": "USER",
    "text": "How much did I spend?",
    "createdAt": "2026-06-12T10:00:00Z",
    "action": null
  },
  "assistantMessage": {
    "id": "784v15jc-15d3-4957-9189-u8e79789ea66",
    "role": "ASSISTANT",
    "text": "There is not enough data to answer.",
    "createdAt": "2026-06-12T10:00:01Z",
    "action": null
  }
}
```

### Start trip from chat

`POST /api/v1/vehicles/{vehicleId}/chat/trips/start`

Creates an in-progress trip timeline event, stores the start timestamp, associates it with
the authenticated user through the vehicle, and links it to the active chat session.

Request:

```json
{
  "startedAt": "2026-06-13T09:15:00Z",
  "notes": "Morning commute"
}
```

Response `201`:

```json
{
  "tripId": "994v15jc-15d3-4957-9189-u8e79789ea66",
  "confirmation": "Trip started. I saved the start time and will keep the record even if details are added later.",
  "missingRequiredFields": ["distanceKm", "fuelLiters", "durationMinutes"],
  "extractedValues": {},
  "trip": {
    "id": "994v15jc-15d3-4957-9189-u8e79789ea66",
    "type": "TRIP",
    "eventDateTime": "2026-06-13T09:15:00Z",
    "startMileageKm": 10000,
    "tripStatus": "IN_PROGRESS"
  }
}
```

### End trip from chat

`POST /api/v1/vehicles/{vehicleId}/chat/trips/{tripId}/end`

Saves the end timestamp and any structured data the client already has. If critical fields
are missing, the trip remains queryable in timeline logs and is saved as partial.

Request:

```json
{
  "endedAt": "2026-06-13T10:10:00Z",
  "distanceKm": 42,
  "durationMinutes": 55,
  "fuelLiters": 4.2,
  "notes": "Home -> University"
}
```

Response `200` contains `missingRequiredFields`; empty means the trip is complete.

### Collect trip data from natural language

`POST /api/v1/vehicles/{vehicleId}/chat/trips/{tripId}/data`

Request:

```json
{
  "text": "We drove 42 km for 55 minutes and used about 4 liters"
}
```

Response `200`:

```json
{
  "tripId": "994v15jc-15d3-4957-9189-u8e79789ea66",
  "confirmation": "I extracted and saved the trip details.",
  "missingRequiredFields": [],
  "extractedValues": {
    "distanceKm": 42,
    "durationMinutes": 55,
    "fuelLiters": 4
  },
  "trip": {
    "id": "994v15jc-15d3-4957-9189-u8e79789ea66",
    "type": "TRIP",
    "distanceKm": 42,
    "durationMinutes": 55,
    "fuelLiters": 4,
    "tripStatus": "COMPLETE"
  }
}
```

If no clear values can be extracted, the backend auto-saves the existing trip data and
returns the remaining missing fields. Partial trips are still returned by
`GET /api/v1/vehicles/{vehicleId}/timeline?type=TRIP`.

If a chat-started trip remains `IN_PROGRESS` after the backend auto-save timeout, the
backend sets `endedAt`, marks it as `PARTIAL`, and keeps it visible in trip logs.

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
      "type": "PART_LIFETIME_WARNING",
      "title": "Brake pads need attention",
      "message": "About 500 km of lifetime remains.",
      "severity": "WARNING",
      "partId": "091f14fc-83d2-4157-9566-j2e63789ea84",
      "remainingKm": 500,
      "recommendedAction": "Plan a brake pad inspection.",
      "read": false,
      "createdAt": "2026-06-12T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1
}
```

### Get notification

`GET /api/v1/notifications/{notificationId}`

Response `200`: notification object.

Errors:

- `404 NOT_FOUND`

### Mark notification as read

`PATCH /api/v1/notifications/{notificationId}`

Request:

```json
{
  "read": true
}
```

Response `200`: updated notification object.

### Notification settings

Notification preferences may be part of a general settings endpoint. If kept
under notifications:

`GET /api/v1/notifications/settings`

Response `200`:

```json
{
  "enabled": true,
  "partLifetimeThresholdKm": 500
}
```

`PATCH /api/v1/notifications/settings`

Request:

```json
{
  "enabled": true,
  "partLifetimeThresholdKm": 500
}
```

Response `200`: updated notification settings.

Rules:

- Disabled notifications stop future delivery but do not delete notification history.
- The notification center remains readable when delivery is disabled.
- Non-urgent notifications for the same part should not be sent more than once per day.
