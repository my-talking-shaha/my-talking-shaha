# Chat API Contract

Base path: `/api/v1/vehicles/{vehicleId}/chat`

Auth: required.

## Get Chat State

`GET /api/v1/vehicles/{vehicleId}/chat`

Returns the vehicle-scoped chat session, three quick questions, and previous messages.

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
      "text": "The assistant is ready.",
      "createdAt": "2026-06-12T10:00:00Z",
      "action": null
    }
  ]
}
```

## Get Chat History

`GET /api/v1/vehicles/{vehicleId}/chat/messages`

Response `200`:

```json
{
  "messages": [
    {
      "id": "125c13vj-13d2-4557-9149-e9e79789ea83",
      "role": "ASSISTANT",
      "text": "The assistant is ready.",
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
    "text": "This looks like something to record in the vehicle history. I can open the REFUEL form and pass the extracted data.",
    "createdAt": "2026-06-12T10:00:01Z",
    "action": {
      "type": "OPEN_FORM",
      "form": "REFUEL",
      "screen": null,
      "prefill": {}
    }
  }
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

## Client Rules

- Chat is scoped by vehicle.
- Do not share messages across vehicles.
- Use `GET /chat` when opening the screen so quick questions are available.
- Render `assistantMessage.action` when present.
- Show retry on network failure.

## Voice Input

Voice-to-text is client-side/platform concern. Backend receives text only unless a future audio endpoint is defined.
