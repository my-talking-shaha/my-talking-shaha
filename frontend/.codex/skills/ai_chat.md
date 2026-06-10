# AI Chat Skill

## Goal

Implement the AI assistant as a per-vehicle grounded interface, not a generic chatbot.

## Product Rules

The assistant represents the selected car. It can answer about:
- current mileage;
- last maintenance;
- part lifetime;
- fuel/refueling history;
- repair history;
- upcoming maintenance suggestions;
- warnings and recommendations.

## Grounding Rule

AI answers must be grounded in stored vehicle data and rule-based calculations.

If the system lacks enough data, display the standard fallback:

```text
Недостаточно данных для ответа
```

Do not invent:
- exact repair dates;
- costs;
- part lifetime;
- sensor readings;
- service appointments;
- community reliability statistics.

## Client Responsibility

The Flutter client should:
- send the user's message to backend with `vehicleId`;
- show optimistic user bubble only when useful;
- show loading/typing state;
- render assistant text;
- render structured recommendation/action cards when returned by backend;
- persist/display chat history from backend;
- scope chat by vehicle.

The Flutter client should not:
- run its own LLM;
- build prompts containing secrets;
- calculate final AI answers independently;
- send data from another vehicle;
- use global chat history for all vehicles.

## Chat UI

- User messages aligned to the right.
- Assistant messages aligned to the left with car/avatar identity.
- Recommendation cards can include part, remaining km, date, action title.
- Input supports text first.
- Voice input is optional/future unless task explicitly asks for it.

## Failure Handling

- Backend no-data response -> show fallback.
- Network error -> show retryable error.
- Unauthorized -> auth handling.
- Message too long -> field-level validation.
