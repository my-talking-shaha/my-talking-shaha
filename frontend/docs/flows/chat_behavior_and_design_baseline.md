# Chat Behavior and Design Baseline

This document captures the shipped mobile chat implementation before the
structure-only refactor. It is the regression source of truth for the refactor.

## Entry and loading

- `/vehicle/:vehicleId/chat` opens chat scoped to that vehicle.
- The top-left chevron returns to `/garage`.
- While the session loads, the screen shows the assistant mark, connection
  title, and preparation text.
- A load failure shows an inline error state with a retry button.
- The backend-only `The assistant is ready.` message is hidden from the user.

## Empty state and input

- An empty conversation shows the assistant mark, title, description, and the
  backend quick questions. If none arrive, three localized fallback questions
  are shown.
- Tapping a quick question sends it exactly like typed text.
- Whitespace-only input is ignored.
- Typing enables the send button; pressing the keyboard send action or the
  arrow sends the same trimmed text.
- The input is cleared immediately after a valid submission and disabled while
  the reply is pending.

## Messages and actions

- A submitted message appears optimistically as a right-aligned user bubble.
- While waiting, an animated left-aligned `Shaha is thinking` bubble is shown.
- Success replaces the optimistic message with backend user and assistant
  messages. Failure keeps the user message and shows a localized snackbar.
- New messages animate the vertical list to its latest extent.
- User bubbles are narrower and blue; assistant bubbles are dark, bordered,
  wider, and include the assistant mark. Both show `HH:mm` time.
- A created timeline event invalidates history, dashboard, and every analytics
  period for the current vehicle.
- Supported `OPEN_SCREEN` actions open analytics, history, dashboard, or the
  maintenance forecast inside the tab shell with `from=chat`.
- Supported `OPEN_FORM` actions open the add-history form outside the tab shell,
  selecting fuel, trip, or maintenance and preserving `mileageKm` when present.
- Unsupported actions are not rendered.

## Gestures and scrolling

- The empty state and message history scroll vertically.
- Quick suggestions below a non-empty conversation scroll horizontally in both
  directions and tapping a chip sends its text.
- Chat has no left/right dismiss, edit, delete, or navigation swipe action.
- The input expands from one to four lines and remains fixed below the content.

## Color baseline

All values below are the exact ARGB colors used by the shipped implementation.
Opacity variants keep the same base color and alpha listed in the UI code.

| Chat token | ARGB | Usage |
| --- | --- | --- |
| `background` | `0xFF10131A` | Page, input, suggestion-strip background |
| `surfaceHigh` | `0xFF1C1F25` | Assistant bubbles, input, tiles, chips |
| `border` | `0xFF2B303B` | Assistant/input/tile borders |
| `primary` | `0xFF2E5BFF` | User bubbles, assistant mark, action accents |
| `primaryLight` | `0xFFB8C3FF` | Borders, action labels, typing gradient |
| `primaryPressed` | `0xFF3F63C9` | User bubble border |
| `textPrimary` | `0xFFF4F7FF` | Message text and typing highlight |
| `textSecondary` | `0xFF9AA3B2` | Suggestion text and typing gradient |
| `textMuted` | `0xFF6F7788` | Assistant timestamps |
| `error` | `0xFFE85D75` | Load error icon |
| `white` | `0xFFFFFFFF` | Assistant icon and translucent user timestamp |
| `black` | `0xFF000000` | Input shadow |
| `transparent` | `0x00000000` | Action-pill Material surface |

## Visual geometry baseline

- Message list padding: `16/24/16/16`.
- User/assistant maximum width: `76%` / `82%`, capped at `620`.
- Bubble corners: `16`, with a `4`-radius speaker-side tail.
- User bubble padding: `18/13/18/8`; assistant: `17/13/17/8`.
- Assistant mark sizes: `84` empty, `72` loading, `36` title, `32` message.
- Input field radius: `20`; send control: `44`; maximum input lines: `4`.
- Suggestion strip height: `44` and horizontal scrolling.
- Typing animation duration: `1100 ms`; auto-scroll duration: `220 ms`.

The reference exports remain in `docs/design/screenshots/chat/`. The shipped
Flutter implementation and the values above take precedence if an older export
shows a component that is not implemented by the current backend/UI contract.
