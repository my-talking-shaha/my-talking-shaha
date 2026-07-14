# Notifications color contract

The shipped notifications UI uses `NotificationsColors` as follows:

| Tokens | UI responsibility |
| --- | --- |
| `unread` | unread card indicator and unread notification category |
| `warning`, `info` | warning and informational notification categories |
| `error` | notification loading/error state |

The remaining background, surface, border, divider and text values capture the feature baseline and match the shared application surfaces, even where widgets currently inherit them from `ThemeData`.
