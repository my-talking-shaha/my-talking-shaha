# Chat Design Notes

## Screens From Design

- `Chat-empty_chat.jpg`
- `Chat-non_empty_no_error_chat.jpg`
- `Chat-non_empty_error_chat.jpg`

## Empty Chat State

Visual structure:
- dark page background;
- top app bar/title;
- centered assistant/car icon;
- text inviting the user to ask a question;
- suggested starter questions;
- bottom input bar;
- bottom navigation.

## Normal Chat State

Message layout:
- user messages aligned to the right;
- assistant messages aligned to the left;
- assistant messages include avatar/icon;
- message bubbles use dark/blue surfaces with borders;
- timestamps are small and muted.

## Error/Insufficient Data State

The assistant error state is shown inside the conversation as a styled assistant response.
It should communicate that the agent cannot answer because data is missing.

Use the standard product meaning:
- if AI cannot answer, show `Not enough data to answer` or localized equivalent;
- do not expose raw backend/model errors.

## Input Bar

The bottom input bar contains:
- text input;
- optional plus/attachment action;
- mic or send button.

Voice input is optional/Could and should not block text chat MVP.

## Implementation Notes

- Use `ChatBubble`, `ChatInputBar`, and `ChatEmptyState`.
- Keep chat history per vehicle.
- Do not let UI invent technical facts; assistant answers must come from backend/rules/mock provider.
