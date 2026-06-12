# AI Chat Flow

## User Stories

Covers:
- CHAT-01 AI chat with car, Must.
- CHAT-02 voice input, Could.
- CHAT-03 start screen with quick questions, Must.
- CHAT-04 chat first, tabs second, Must.
- CHAT-05 chat to pre-filled form, Must.
- CHAT-06 chat history, Should.

## Screens

- Per-vehicle chat screen.
- Chat message list.
- Text input.
- Optional voice input.
- Recommendation card.
- Quick-question buttons.
- Pre-filled event forms launched from chat.

## Chat Flow

1. User opens `/vehicle/:vehicleId/chat`.
2. Client loads chat history for selected vehicle.
3. User types a message in natural language.
4. Client validates non-empty input.
5. Client sends message to backend with vehicle ID.
6. Backend responds using vehicle data and rules.
7. Client appends assistant response.
8. History remains available after next login.

## Start Screen and Quick Questions Flow

1. User opens the primary chat entry point for the selected vehicle.
2. The chat screen is open by default for that entry point.
3. User can type a message immediately.
4. Quick-question buttons are shown below the input field.
5. Starter set:
   - `Состояние авто`;
   - `Когда ТО?`;
   - `Что может сломаться?`;
   - `Добавить заправку`;
   - `Записать ремонт`.
6. Buttons may be dynamic and personalized for the selected user and vehicle.
7. User taps a quick-question button.
8. The question is sent to the chat as a user message.

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

For CHAT-05, backend must support structured actions for these recognized event intents:
- repair;
- refuel;
- trip.

Flutter should render structured actions but not invent them.

## Chat to Form Flow

1. User sends a message about an event, for example `Заменил масло на 15000 км`.
2. Backend recognizes the event intent and extracts known fields.
3. Assistant responds with a confirmation question and a `Перейти к форме` action.
4. Structured action payload includes:
   - event type;
   - target form route;
   - pre-filled fields;
   - return route to the current chat.
5. User taps `Перейти к форме`.
6. App opens the matching form with extracted fields pre-filled.
7. User completes remaining fields and saves.
8. App returns to the chat and appends an AI confirmation.
9. User can cancel the action before saving.

Example for `Заменил масло на 15000 км`:
- event type: part replacement;
- part: oil;
- mileage: 15000.

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
- Quick-question buttons are available on the chat start screen.
- Recognized event intents can open pre-filled forms and return to chat after save.
