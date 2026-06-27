# Auth API Contract

## Current Mobile Implementation

The mobile client currently uses `MockAuthDatasource` through the `AuthDatasource` interface. No backend auth endpoint is called yet.

Current session shape:

```json
{
  "token": "mock-token-driver",
  "login": "driver",
  "fullName": "Demo Driver"
}
```

Current secure storage keys:
- `auth_token`
- `auth_login`
- `auth_full_name`

Demo account:

```json
{
  "login": "driver",
  "password": "password123",
  "fullName": "Demo Driver"
}
```

Current mock errors:
- register with login `existing`: `Login already exists`;
- register with a password shorter than 8 characters: `The password does not satisfy the requirements`;
- login with unknown login or wrong password: `Login or password are incorrect`;
- login with login `network`: `Network error. Please try again later`.

## Current Datasource Interface

The app depends on this client-side contract:

```dart
abstract interface class AuthDatasource {
  Future<AuthSession> register(RegistrationCredentials credentials);
  Future<AuthSession> login(LoginCredentials credentials);
  Future<void> logout(String token);
}
```

Registration credentials:

```json
{
  "fullName": "John Smith",
  "login": "john",
  "password": "password123"
}
```

Login credentials:

```json
{
  "login": "john",
  "password": "password123"
}
```

## Future Backend Contract

The backend-backed auth datasource should preserve the app-level `AuthDatasource` interface above and map backend responses into `AuthSession`.

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
  "fullName": "John Smith",
  "login": "john",
  "password": "password123"
}
```

Response `201`:

```json
{
  "user": {
    "id": "user_123",
    "login": "john",
    "fullName": "John Smith"
  },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

Client notes:
- current mobile validation requires fields and matching password confirmation;
- current datasource enforces password min length: 8;
- after success, backend must create empty garage;
- client maps the returned access token, login, and full name into `AuthSession`;
- client stores the session and navigates to `/garage`.

Errors:
- `409 LOGIN_ALREADY_EXISTS`;
- `400 VALIDATION_ERROR`.

## Login

`POST /api/v1/auth/login`

Request:

```json
{
  "login": "john",
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

Headers: `Authorization: Bearer <token>`

Request:

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

Response `204`.

Current mobile behavior restores the previous session if logout throws. When backend logout is introduced, product should decide whether local session must still be cleared after a network failure.
