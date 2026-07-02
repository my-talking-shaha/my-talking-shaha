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

AI chat answers are written as the selected vehicle speaking directly to the user, in
first person. The backend should not answer like a generic app assistant unless a future
personality mode explicitly asks for that.

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
3. If all required fields are present and valid, backend creates the event immediately
   and returns `createdEvent` with a confirmation message.
4. If fields are missing or invalid, assistant asks for the missing/corrected values and
   keeps the extracted fields as a pending draft.
5. If automatic creation is not possible for the intent, assistant may return a
   `Перейти к форме` action.
6. Structured action payload includes:
   - event type;
   - target form route;
   - pre-filled fields;
   - return route to the current chat.
7. User taps `Перейти к форме`.
8. App opens the matching form with extracted fields pre-filled.
9. User completes remaining fields and saves.
10. App returns to the chat and appends an AI confirmation.
11. User can cancel the action before saving.

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

## Automatic Chat Event Creation

When a chat message contains all required event fields, backend creates the timeline
event immediately instead of only returning an `OPEN_FORM` action.

Supported automatic creation intents:
- refuel: liters, cost, fuel type/name, mileage if present;
- trip: distance and duration;
- repair/maintenance: repair text, mileage if present, cost if present.

If required fields are missing, backend keeps the extracted fields as a pending chat draft
and asks the user to provide the missing data. If validation fails, backend explains what
is wrong and asks for corrected values. For example, `Я заправляла машину на 5 литров
95-м бензином` should make the car ask for cost; `за 1000 рублей` should then complete
the pending draft and create the `REFUEL` event.

Example complete refuel message:

```text
Я заправилась на 5 литров 95-м бензином за 1000 рублей
```

Expected behavior:
- backend validates extracted data using timeline rules;
- backend creates a `REFUEL` timeline event;
- assistant returns a confirmation message without an action;
- response includes `createdEvent`;
- client refreshes timeline/dashboard/analytics data after receiving `createdEvent`.
- supported fuel names are limited to the current form values: `92 octane`, `95 octane`,
  `98 octane`, and `Diesel`.

Generic repair messages such as `Я хочу записать ремонт` are not enough to create an
event. The car should ask for the work description and any invalid or missing validation
fields, then create the maintenance record only after the user sends valid details.
