# Auth API Contract

Base path: `/api/v1/auth`

## Error Format

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Validation failed",
  "details": {}
}
```

## Register

`POST /api/v1/auth/register`

Request:

```json
{
  "email": "user@example.com",
  "password": "secret123"
}
```

Response `201`:

```json
{
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "displayName": null
  },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

Client notes:
- password min length: 6;
- after success, backend must create empty garage;
- client stores tokens and navigates to `/garage`.

Errors:
- `409 EMAIL_ALREADY_EXISTS`;
- `400 VALIDATION_ERROR`.

## Login

`POST /api/v1/auth/login`

Request:

```json
{
  "email": "user@example.com",
  "password": "secret123"
}
```

Response `200`: same as register.

Errors:
- `401 INVALID_CREDENTIALS`.

## YandexID Auth

Priority: Should.

`POST /api/v1/auth/yandexid`

Request:

```json
{
  "idToken": "yandex-id-token"
}
```

Response `200`: same as login.

Client notes:
- YandexID auth creates account if not present;
- email from YandexID becomes primary email.

## Refresh Token

`POST /api/v1/auth/refresh`

Request:

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

Response:

```json
{
  "accessToken": "new-access-token",
  "refreshToken": "new-refresh-token"
}
```

## Logout

`POST /api/v1/auth/logout`

Headers: `Authorization: Bearer <token>`

Request:

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

Response `204`.

Client must clear local session even if server logout fails with network error after user confirms.
