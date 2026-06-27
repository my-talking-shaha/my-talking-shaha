# Auth API Contract

Base path: `/api/v1/auth`

## Error Format

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Request contains invalid fields",
  "fields": {
    "password": "Password must be between 6 and 72 characters"
  }
}
```

## Register

`POST /api/v1/auth/register`

Request:

```json
{
  "email": "user@example.com",
  "password": "secret123",
  "displayName": "Test User"
}
```

Response `201`:

```json
{
  "user": {
    "id": "045c10aa-13d1-4599-9109-e9e79789ea91",
    "email": "user@example.com",
    "displayName": "Test User"
  },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

Client notes:
- `displayName` is required;
- password rules: 6–72 characters; allowed characters are letters (a-z, A-Z), digits, and `()[]$#*-_?!.%+<>/`;
- after success, the backend creates the account; the garage starts empty (vehicles are owned per user);
- the user is signed in automatically;
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
