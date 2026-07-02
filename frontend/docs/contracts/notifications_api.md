# Notifications API Contract

Base path: `/api/v1/notifications`

Auth: required.

Priority: Should / planned.

## List Notifications

`GET /api/v1/notifications?page=0&size=20`

Response:

```json
{
  "items": [
    {
      "id": "notif_123",
      "vehicleId": "vehicle_123",
      "type": "part_lifetime_warning",
      "severity": "WARNING",
      "title": "Oil change due soon",
      "message": "450 km remaining before the recommended replacement",
      "partId": "part_123",
      "remainingKm": 450,
      "recommendedAction": "Schedule oil replacement",
      "createdAt": "2026-06-10T10:00:00Z",
      "read": false
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1
}
```

## Get Notification

`GET /api/v1/notifications/{notificationId}`

Response: notification object.

## Mark as Read

`PATCH /api/v1/notifications/{notificationId}`

Request:

```json
{
  "read": true
}
```

Response: updated notification.

## Notification Settings

Can be included in `settings_api.md`; if a separate endpoint is used:

`GET /api/v1/notifications/settings`

Response:

```json
{
  "enabled": true,
  "partLifetimeThresholdKm": 500
}
```

`PATCH /api/v1/notifications/settings`

Request:

```json
{
  "enabled": true,
  "partLifetimeThresholdKm": 500
}
```

## Push Payload

```json
{
  "notificationId": "notif_123",
  "vehicleId": "vehicle_123",
  "partId": "part_123",
  "screen": "part_details",
  "type": "part_lifetime_warning"
}
```

## Rules

- No more than one non-urgent notification per day for the same part.
- Tapping opens relevant screen.
- Client must handle disabled notifications.
- Disabled notifications do not remove existing notification history.
- Client must handle empty, loading, and error states for the notification list.
