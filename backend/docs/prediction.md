# AI chat and prediction module

## Product idea

The application starts with the vehicle chat. The chat is the main way to ask about vehicle state, get maintenance recommendations, and start data entry.

## MVP approach

Stages:

1. Backend-grounded chat answers through an OpenAI-compatible chat completions API.
2. Backend intent validation and fallback rules for common parts, forms, analytics, and maintenance forecast.
3. Configurable rules in application config or the database.
4. Later: model-based predictions using collected user data.

The chat uses the OpenAI-compatible endpoint configured by `TIMEWEB_AI_BASE_URL` when
`TIMEWEB_AI_TOKEN` is configured. If the token is
missing or the provider is unavailable, the backend falls back to local intent rules and
template answers.

## Assistant context

Before generating or selecting an answer, the backend should prepare a compact context:

```json
{
  "vehicle": {
    "brand": "Lada",
    "model": "2106",
    "mileageKm": 10000,
    "fuelType": "GASOLINE"
  },
  "maintenanceForecast": {
    "overallStatus": "ATTENTION",
    "criticalParts": [
      {
        "name": "Timing belt",
        "remainingKm": 0,
        "remainingPercent": 0
      }
    ],
    "attentionParts": [
      {
        "name": "Engine oil",
        "remainingKm": 500,
        "remainingPercent": 8
      }
    ]
  },
  "recentEvents": [
    {
      "type": "REFUEL",
      "date": "2026-06-12",
      "mileageKm": 10000,
      "summary": "30 liters of 95 octane fuel, 2000 RUB"
    }
  ],
  "analytics": {
    "totalExpenses": 5000,
    "costPerKm": 5
  }
}
```

## Quick questions

Quick questions are dynamic buttons under the chat input.

Base set:

- "Vehicle status"
- "When is the next service?"
- "What can break soon?"
- "Add a refuel"
- "Record a repair"

Dynamic examples:

- "Should I change the oil?" if the oil remaining lifetime is below the threshold;
- "Check brakes" if brake pads are in `ATTENTION` or `CRITICAL` status;
- "Add the first vehicle" if the garage is empty.

The backend can return quick questions from `GET /api/v1/vehicles/{vehicleId}/chat`.

## Supported intents

The chat should identify the user's intent, extract simple structured data when possible, and return either a direct answer or an action for the mobile app. The first MVP should support at least these intents:

| Intent | Example | Backend action |
| --- | --- | --- |
| `ASK_CAR_STATUS` | "How is my car doing?" | Return dashboard and forecast summary. |
| `ASK_MILEAGE` | "What is the current mileage?" | Return current vehicle mileage. |
| `ASK_NEXT_SERVICE` | "When is the next service?" | Return next service estimate. |
| `ASK_EXPENSES` | "How much did I spend this year?" | Return analytics summary. |
| `CREATE_REFUEL` | "I refueled 30 liters for 2000" | Return an action to open the refuel form with prefilled data. |
| `CREATE_REPAIR` | "I replaced the brake pads" | Return an action to open the repair form with prefilled data. |
| `CREATE_TRIP` | "I drove from home to university for 10 km" | Return an action to open the trip form with prefilled data. |
| `CREATE_PART_REPLACEMENT` | "I changed the oil at 10000 km" | Return an action to open the part replacement form with prefilled data. |

For safety, the language model may classify the natural-language message and draft the
answer, but the backend still validates the intent and creates the final structured
frontend action.

## Action response

When the assistant suggests a form, the backend returns an `action` inside the assistant message:

```json
{
  "role": "ASSISTANT",
  "text": "Do you want to add a part replacement record?",
  "action": {
    "type": "OPEN_FORM",
    "form": "PART_REPLACEMENT",
    "prefill": {
      "partName": "Engine oil",
      "mileageKm": 10000
    }
  }
}
```

## Rule-based prediction

Input data:

- current vehicle mileage;
- installed parts;
- expected lifetime in kilometers;
- maintenance history;
- threshold configuration.

Output data:

- remaining kilometers for each part;
- remaining percentage;
- status;
- recommendation text;
- next service estimate.

Status rules:

```text
UNKNOWN   if expectedLifetimeKm is absent
CRITICAL  if remainingKm <= 0
ATTENTION if remainingPercent < 10
OK        otherwise
```

Notification candidate:

```text
Create a warning if remainingKm < 500 and the user has not received the same warning today.
```

## Example recommendations

| Part | Default lifetime | Recommendation |
| --- | ---: | --- |
| Engine oil | 8 000 km | "Plan an engine oil replacement." |
| Brake pads | 25 000 km | "Inspect the brake pads." |
| Battery | 60 000 km | "Check the battery charge and condition." |
