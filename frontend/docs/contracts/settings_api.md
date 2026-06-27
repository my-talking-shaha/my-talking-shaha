# Profile and Settings API Contract

Base path: `/api/v1/settings`

Auth: required.

Profile identity is owned by the authenticated user API, not the settings API.
Use `GET /api/v1/users/me` for read-only profile header data.

## Get Current Profile

`GET /api/v1/users/me`

Response:

```json
{
  "id": "user_123",
  "email": "driver@example.com",
  "displayName": "Alex Driver",
  "avatarUrl": "https://example.com/avatar.png"
}
```

Client notes:

- `avatarUrl` is optional.
- If `displayName` is empty, fall back to email or initials.
- Editable profile fields require a separate account/profile endpoint.

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
- Disabling notifications stops future delivery but does not delete notification
  history.
- Logout belongs to auth flow, not settings API.
