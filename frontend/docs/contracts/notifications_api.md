# Notifications API Contract

Base path: `/api/v1/notifications`

Auth: required.

Priority: Could / Week 6+.

## List Notifications

`GET /api/v1/notifications`

Response:

```json
{
  "notifications": [
    {
      "id": "notif_123",
      "vehicleId": "vehicle_123",
      "type": "part_lifetime_warning",
      "title": "Скоро замена масла",
      "message": "Осталось 450 км до рекомендуемой замены",
      "partId": "part_123",
      "remainingKm": 450,
      "recommendedAction": "Запланировать замену масла",
      "createdAt": "2026-06-10T10:00:00Z",
      "read": false
    }
  ]
}
```

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

Can be included in `settings_api.md`; if separate endpoint is used:

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
  "screen": "part_details"
}
```

## Rules

- No more than one non-urgent notification per day for the same part.
- Tapping opens relevant screen.
- Client must handle disabled notifications.
