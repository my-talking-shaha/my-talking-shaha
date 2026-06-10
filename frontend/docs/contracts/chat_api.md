# Chat API Contract

Base path: `/api/v1/vehicles/{vehicleId}/chat`

Auth: required.

## Get Chat History

`GET /api/v1/vehicles/{vehicleId}/chat/messages`

Response:

```json
{
  "messages": [
    {
      "id": "msg_1",
      "role": "user",
      "text": "Когда менять масло?",
      "createdAt": "2026-06-10T14:20:00Z"
    },
    {
      "id": "msg_2",
      "role": "assistant",
      "text": "Судя по пробегу, через 1500 км стоит заменить масло.",
      "createdAt": "2026-06-10T14:21:00Z",
      "grounded": true,
      "cards": [
        {
          "type": "maintenance_recommendation",
          "title": "Ближайшее действие",
          "description": "Замена масла через 1500 км",
          "action": {
            "type": "open_part",
            "partId": "part_123"
          }
        }
      ]
    }
  ]
}
```

## Send Message

`POST /api/v1/vehicles/{vehicleId}/chat/messages`

Request:

```json
{
  "text": "Когда менять масло?"
}
```

Response `201`:

```json
{
  "userMessage": {
    "id": "msg_1",
    "role": "user",
    "text": "Когда менять масло?",
    "createdAt": "2026-06-10T14:20:00Z"
  },
  "assistantMessage": {
    "id": "msg_2",
    "role": "assistant",
    "text": "Судя по пробегу, через 1500 км стоит заменить масло.",
    "createdAt": "2026-06-10T14:21:00Z",
    "grounded": true,
    "cards": []
  }
}
```

## Insufficient Data

If the AI cannot answer:

```json
{
  "userMessage": { "id": "msg_1", "role": "user", "text": "..." },
  "assistantMessage": {
    "id": "msg_2",
    "role": "assistant",
    "text": "Недостаточно данных для ответа",
    "grounded": false,
    "cards": []
  }
}
```

## Client Rules

- Chat is scoped by vehicle.
- Do not share messages across vehicles.
- Do not generate local AI answers.
- Render backend cards if provided.
- Show retry on network failure.

## Voice Input

Voice-to-text is client-side/platform concern. Backend receives text only unless a future audio endpoint is defined.
