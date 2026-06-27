# Auth API Contract

## Current Mobile Implementation

The mobile client uses `AuthApiDatasource` through the `AuthDatasource` interface and calls the backend auth API.

Current session shape:

```json
{
  "token": "jwt-access-token",
  "refreshToken": "jwt-refresh-token",
  "login": "driver@example.com",
  "fullName": "Demo Driver"
}
```

Current secure storage keys:
- `auth_token`
- `auth_refresh_token`
- `auth_login`
- `auth_full_name`

## Current Datasource Interface

The app depends on this client-side contract:

```dart
abstract interface class AuthDatasource {
  Future<AuthSession> register(RegistrationCredentials credentials);
  Future<AuthSession> login(LoginCredentials credentials);
  Future<void> logout(String refreshToken);
}
```

Registration credentials:

```json
{
  "fullName": "John Smith",
  "login": "john@example.com",
  "password": "password123"
}
```

Login credentials:

```json
{
  "login": "john@example.com",
  "password": "password123"
}
```

The app-level `login` field is mapped to backend `email`.

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
  "email": "john@example.com",
  "password": "password123",
  "displayName": "John Smith"
}
```

Mobile source credentials:

```json
{
  "fullName": "John Smith",
  "login": "john@example.com",
  "password": "password123"
}
```

Response `201`:

```json
{
  "user": {
    "id": "045c10aa-13d1-4599-9109-e9e79789ea91",
    "email": "john@example.com",
    "displayName": "John Smith"
  },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

Client notes:
- current mobile validation requires fields and matching password confirmation;
- after success, backend must create empty garage;
- client maps the returned access token, refresh token, email, and display name into `AuthSession`;
- client stores the session and navigates to `/garage`.

Errors:
- `409 EMAIL_ALREADY_EXISTS`;
- `400 VALIDATION_ERROR`.

## Login

`POST /api/v1/auth/login`

Request:

```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

Response `200`: same as register.

Errors:
- `401 INVALID_CREDENTIALS`.

## Yandex ID Auth

Status: future integration. The mobile UI currently shows the button, but no OAuth/backend flow is connected.

`POST /api/v1/auth/yandexid`

Request:

```json
{
  "idToken": "yandex-id-token"
}
```

Response `200`: same as login.

Client notes:
- Yandex ID auth creates account if not present;
- login/full name mapping must be agreed with backend/product before implementation.

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

Request:

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

Response `204`.

Current mobile behavior restores the previous session if logout throws. Restored legacy sessions that do not contain `auth_refresh_token` are cleared locally without a backend logout call.
