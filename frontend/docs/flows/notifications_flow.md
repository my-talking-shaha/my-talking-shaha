# Notifications Flow

## User Stories

Covers:
- NOTIF-01 warnings about possible malfunctions, Could.

## Screens

- Notification center.
- Notification details.
- Notification settings toggle.

## Notification Trigger

Priority: Could.

A notification may be generated when:
- part remaining lifetime falls below 500 km;
- user-defined threshold is reached;
- backend generates maintenance recommendation.

Notification content:
- part name;
- remaining resource;
- recommended action;
- related vehicle.

## Notification Center Flow

1. User opens `/notifications`.
2. Client fetches notifications.
3. Notifications are grouped by date/status.
4. User taps notification.
5. App opens detail or related part/recommendation screen.

## Push Flow

1. Backend sends push.
2. User taps push.
3. App opens notification detail or related vehicle part screen.

## Anti-spam Rule

Do not notify more than once per day for the same part unless backend explicitly marks it urgent.

## Settings

User can enable/disable notifications in settings.

## Acceptance Criteria

- Push notification includes part name, remaining resource, and action.
- Tapping notification opens relevant screen.
- User can turn notifications on/off.
- App has screen with received notifications.
