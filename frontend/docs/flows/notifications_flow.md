# Notifications Flow

## User Stories

Covers:
- NOTIF-01 warnings about possible malfunctions, Should.

Notifications cover in-app notification history and push/deep-link behavior.
The documented flow is the target product behavior even if the current client
uses local or mocked notification data.

## Screens

- Notification center.
- Notification details.
- Notification settings toggle.

## Notification Types

Supported notification types:

- part lifetime warning;
- maintenance reminder;
- system message.

## Notification Trigger

Priority: Should.

A notification may be generated when:

- part remaining lifetime falls below 500 km;
- user-defined threshold is reached;
- backend generates maintenance recommendation.

Notification content:

- notification id;
- type and severity;
- part name;
- remaining resource;
- recommended action;
- related vehicle.

## Notification Center Flow

1. User opens `/notifications`.
2. Client fetches notifications with pagination.
3. Notifications are shown newest first and may be grouped by date/status.
4. User taps notification.
5. App marks the notification as read when supported.
6. App opens detail or related part/recommendation screen.

The notification center remains accessible when push notifications are disabled.
The toggle controls future delivery, not existing history visibility.

## Notification Details Flow

1. User opens `/notifications/:notificationId`.
2. Client loads the selected notification.
3. Screen shows full message, created time, related vehicle, remaining resource,
   and recommended action when available.
4. If a related route exists, user can open the related vehicle, part, dashboard,
   or recommendation screen.

## Push Flow

1. Backend sends push.
2. User taps push.
3. App opens notification detail or related vehicle part screen.

## Anti-spam Rule

Do not notify more than once per day for the same part unless backend explicitly marks it urgent.

## Settings

User can enable/disable notifications in settings.
The preference should sync with the settings/notifications contract when the
backend endpoint is available.

## Acceptance Criteria

- Push notification includes part name, remaining resource, and action.
- Tapping notification opens relevant screen.
- User can turn notifications on/off.
- App has screen with received notifications.
- Notification history handles empty, loading, and error states.
- Read/unread state is visible when provided by API.
