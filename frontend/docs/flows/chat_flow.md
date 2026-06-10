# AI Chat Flow

## User Stories

Covers:
- CHAT-01 AI chat with car, Must.
- CHAT-02 voice input, Could.

## Screens

- Per-vehicle chat screen.
- Chat message list.
- Text input.
- Optional voice input.
- Recommendation card.

## Chat Flow

1. User opens `/vehicle/:vehicleId/chat`.
2. Client loads chat history for selected vehicle.
3. User types a message in natural language.
4. Client validates non-empty input.
5. Client sends message to backend with vehicle ID.
6. Backend responds using vehicle data and rules.
7. Client appends assistant response.
8. History remains available after next login.

## Grounding Requirements

AI agent answers must be based on:
- vehicle profile;
- current mileage;
- timeline events;
- parts and lifetime;
- maintenance rules;
- backend-provided recommendations.

If data is missing, show exact fallback:

```text
Недостаточно данных для ответа
```

## Response Content

Where possible, response should include concrete:
- mileage;
- remaining resource;
- date;
- event reference;
- recommendation.

## Structured Actions

Backend may return cards such as:
- nearest maintenance recommendation;
- part replacement warning;
- add event shortcut;
- open part details.

Flutter should render structured actions but not invent them.

## Voice Input

Priority: Could.

If implemented:
- mic button starts recording;
- speech converts to text;
- converted text appears in input;
- user can edit before sending;
- handle recognition failure with retry message;
- support iOS and Android permissions.

## Acceptance Criteria

- Chat section exists.
- User can send text messages.
- AI answers based on car data/rules.
- Answers include numbers where possible.
- If AI cannot answer, fallback is shown.
- Chat history is saved per vehicle.
