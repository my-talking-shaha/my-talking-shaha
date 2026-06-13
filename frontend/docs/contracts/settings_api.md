# Settings API Contract

Base path: `/api/v1/settings`

Auth: required.

## Get Settings

`GET /api/v1/settings`

Response:

```json
{
  "theme": "system",
  "language": "ru",
  "notificationsEnabled": true,
  "partLifetimeThresholdKm": 500
}
```

## Update Settings

`PATCH /api/v1/settings`

Request:

```json
{
  "theme": "dark",
  "language": "ru",
  "notificationsEnabled": true,
  "partLifetimeThresholdKm": 500
}
```

Response: updated settings.

## Values

Theme:

```text
system
dark
light
```

Language:

```text
ru
en
```

## Client Notes

- Theme and language may be local-only in early MVP.
- Notification preferences should sync with backend when notifications are implemented.
- Logout belongs to auth flow, not settings API.
