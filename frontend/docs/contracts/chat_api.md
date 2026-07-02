# Chat API Contract

Base path: `/api/v1/vehicles/{vehicleId}/chat`

Auth: required.

## Get Chat State

`GET /api/v1/vehicles/{vehicleId}/chat?language=EN`

Returns the vehicle-scoped chat session, three quick questions, and previous messages.
`language` is optional (`EN` or `RU`) and is used for the initial assistant message and
fallback quick questions when the session has no user messages yet.

Response `200`:

```json
{
  "sessionId": "034c13vc-13d2-4557-9169-e9e79789ea49",
  "quickQuestions": [
    "Vehicle status",
    "What are my total expenses?",
    "What can break soon?"
  ],
  "messages": [
    {
      "id": "125c13vj-13d2-4557-9149-e9e79789ea83",
      "role": "ASSISTANT",
      "text": "Hi! I am your car, and I am ready to chat.",
      "createdAt": "2026-06-12T10:00:00Z",
      "action": null
    }
  ]
}
```

## Get Chat History

`GET /api/v1/vehicles/{vehicleId}/chat/messages?language=EN`

Response `200`:

```json
{
  "messages": [
    {
      "id": "125c13vj-13d2-4557-9149-e9e79789ea83",
      "role": "ASSISTANT",
      "text": "Hi! I am your car, and I am ready to chat.",
      "createdAt": "2026-06-12T10:00:00Z",
      "action": null
    }
  ]
}
```

## Send Message

`POST /api/v1/vehicles/{vehicleId}/chat/messages`

Request:

```json
{
  "text": "I refueled the car today"
}
```

Response `201`:

```json
{
  "userMessage": {
    "id": "533c17vc-13d5-6857-5269-e9e80739ea42",
    "role": "USER",
    "text": "I refueled the car today",
    "createdAt": "2026-06-12T10:00:00Z",
    "action": null
  },
  "assistantMessage": {
    "id": "784v15jc-15d3-4957-9189-u8e79789ea66",
    "role": "ASSISTANT",
    "text": "I want to record the refuel in my history, but I need more details: liters and cost. Send the missing values in one message.",
    "createdAt": "2026-06-12T10:00:01Z",
    "action": null
  },
  "createdEvent": null
}
```

## Actions

The backend validates all frontend actions. The client should not invent app routes.

Open form:

```json
{
  "type": "OPEN_FORM",
  "form": "REFUEL",
  "screen": null,
  "prefill": {
    "mileageKm": 10000
  }
}
```

Supported forms:

- `REFUEL`
- `TRIP`
- `PART_REPLACEMENT`
- `MAINTENANCE`

Open screen:

```json
{
  "type": "OPEN_SCREEN",
  "form": null,
  "screen": "ANALYTICS",
  "prefill": {}
}
```

Supported screens:

- `ANALYTICS`
- `MAINTENANCE_FORECAST`
- `DASHBOARD`

## Fallbacks

If there is not enough data, the assistant message contains a localized fallback text and no unsupported facts.

If the question is unclear, the assistant message contains suggestions about what the user might have meant.

Chat responses are written as the selected car speaking directly to the user, not as a
generic app assistant. Casual messages such as greetings or "How are you?" should receive
a grounded Shaha-style response using vehicle context. Fuel-level questions should not
invent live tank sensor data; the car may answer from fuel history and consumption only.

## Automatic Event Creation

If the message contains enough validated event data, the backend may create the timeline
event immediately and return a confirmation message without an action:

```json
{
  "userMessage": {
    "id": "533c17vc-13d5-6857-5269-e9e80739ea42",
    "role": "USER",
    "text": "I refueled 95 octane gas for 5 liters for 1000 rubles",
    "createdAt": "2026-06-12T10:00:00Z",
    "action": null
  },
  "assistantMessage": {
    "id": "784v15jc-15d3-4957-9189-u8e79789ea66",
    "role": "ASSISTANT",
    "text": "I recorded my refuel: 5 L 95 octane, 1000 RUB. My mileage is now 10000 km.",
    "createdAt": "2026-06-12T10:00:01Z",
    "action": null
  },
  "createdEvent": {
    "id": "994v15jc-15d3-4957-9189-u8e79789ea66",
    "type": "REFUEL",
    "title": "Заправка",
    "eventDateTime": "2026-06-12T10:00:01Z",
    "mileageKm": 10000,
    "liters": 5,
    "cost": 1000,
    "fuelType": "GASOLINE",
    "fuelName": "95 octane"
  }
}
```

When required data for an event type is incomplete, the backend asks the user to provide
the missing fields in chat and keeps the extracted fields as a pending draft. For example,
after `I refueled the car with 5 liters of 95 octane.`, the car asks for the cost; after
`for 1000 rubles`, it validates the combined data and creates the event. If any field is
invalid, the response explains what is wrong and asks for corrected values.

For chat-created refuel records, accepted `fuelName` values are limited to the current
form options: `92 octane`, `95 octane`, `98 octane`, and `Diesel`.

For repair/maintenance records, generic intent messages such as `I want to record the repair`
must not create an event by themselves. The backend asks for the work description and any
missing validation fields, then creates the event only after the user provides valid data.

## Client Rules

- Chat is scoped by vehicle.
- Do not share messages across vehicles.
- Use `GET /chat` when opening the screen so quick questions are available.
- Render `assistantMessage.action` when present.
- When `createdEvent` is not null, refresh timeline, dashboard, and analytics data.
- Show retry on network failure.

## Voice Input

Voice-to-text is client-side/platform concern. Backend receives text only unless a future audio endpoint is defined.
