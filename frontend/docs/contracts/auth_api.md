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

## Yandex ID Auth

Status: future work. There is no Yandex ID UI flow and no backend endpoint in the current MVP scope.

When the feature is implemented later, product, frontend, and backend should agree the OAuth flow, endpoint shape, and user identity mapping before adding UI or API contract details.

## Refresh Token

`POST /api/v1/auth/refresh`

Request:

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

Response `200`:

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
