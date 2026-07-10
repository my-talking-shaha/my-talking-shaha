# Notifications Current Baseline

This document records the shipped mobile behavior and visual tokens before the
notifications presentation refactor. It is the regression source of truth for
that refactor; the target product flow remains documented in
`notifications_flow.md`.

## Notification center behavior

- Opening `/notifications` starts an auto-disposed asynchronous list request.
- While loading, the screen shows a centered circular progress indicator.
- A successful non-empty response is rendered in repository order. The mock
  repository currently returns the newest notification first.
- Each card shows an icon chosen by notification type, title, `dd.MM.yyyy`
  date, a preview limited to 118 characters and two visual lines, and an unread
  dot when `read == false`.
- Tapping a card pushes `/notifications/:notificationId`.
- Pulling the list down triggers a fresh list request through Riverpod.
- Horizontal swipes have no action: cards are not dismissed, reordered, or
  marked as read. There are no forms in this feature.
- An empty response shows the localized `noNotificationsYet` text.
- A failed response shows the network error icon, localized title/message, and
  a retry action that invalidates the list provider.

## Details behavior

- Opening `/notifications/:notificationId` looks up the item in the same list.
- While loading, the screen shows a centered circular progress indicator.
- A found item shows `dd.MM.yyyy, HH:mm`, its full title and description, then
  the remaining resource and/or recommended action when present.
- Remaining resource is formatted as `<value> km`.
- A missing id shows the localized `notificationNotFound` text.
- A failed lookup shows the network error icon and retry action.
- System back returns to the notification center and then to the previous tab.

## Visual baseline

The regression snapshot is
`test/features/notifications/presentation/goldens/notifications_screen.png` at
430 x 932 logical pixels using `AppTheme.dark` and the English locale.

The exact feature palette is centralized in
`lib/features/notifications/presentation/colors.dart`:

| Role | ARGB / hex |
| --- | --- |
| Screen background | `0xFF10131A` |
| Card surface | `0xFF191A21` |
| Card border | `0xFF2B303B` |
| Divider | `0xFF252A33` |
| Primary text | `0xFFF4F7FF` |
| Secondary text | `0xFF9AA3B2` |
| Muted text | `0xFF6F7788` |
| Unread/system accent | `0xFFB8C3FF` |
| Warning accent | `0xFFE8B950` |
| Error accent | `0xFFE85D75` |
| Maintenance/info accent | `0xFF82A8BA` |

Spacing, radius, and typography continue to come from the application design
system. The refactor must not alter their resolved values.
