# Chat color contract

The shipped chat UI uses `ChatColors` as follows:

| Tokens | UI responsibility |
| --- | --- |
| `background`, `surfaceHigh`, `border`, `black` | input area, suggestion strip, message/typing bubbles and shadows |
| `primary`, `primaryLight`, `primaryPressed` | user bubble, assistant mark, actions, suggestions and pressed state |
| `textPrimary`, `textSecondary`, `textMuted`, `white` | message text, metadata and text/icons on accent surfaces |
| `error` | chat error state |
| `transparent` | action-pill outline-only state |

These roles must remain stable when shared values move into the application theme.
