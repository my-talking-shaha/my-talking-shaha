# Auth Flow

## User Stories

Covers:
- ACC-01 Registration with login/password.
- ACC-02 Yandex ID auth, future work.

## Current Implementation Status

- Auth is implemented in the mobile client with `AuthController`, `AuthRepositoryImpl`, `AuthSecureStorage`, and `AuthApiDatasource`.
- The current datasource calls the backend auth API under `/api/v1/auth`.
- The session contains `token`, `refreshToken`, `login`, and `fullName`.
- Session data is persisted in `flutter_secure_storage` under `auth_token`, `auth_refresh_token`, `auth_login`, and `auth_full_name`.
- Route protection is active: unauthenticated users are sent to `/login`, authenticated users are sent away from auth screens to `/garage`, and session restoration uses `/auth` as a loading route.

## Screens

- Login screen.
- Registration screen.
- Session restoration loading screen at `/auth`.
- Forgot password link placeholder.
- Yandex ID is out of the current UI scope.

## Registration Flow

1. User opens registration screen.
2. User enters full name, email, password, and confirm password.
3. Client validates required fields and matching password confirmation.
4. Client sends registration request to the current auth datasource.
5. On success:
   - backend creates the account and returns an auth response;
   - datasource maps access token, refresh token, email, and display name into the session;
   - client stores session;
   - user is navigated to `/garage`.
6. If email already exists, show conflict error.
7. If password is too short, show validation error.

## Login Flow

1. User opens login screen.
2. User enters login and password.
3. Client validates required fields.
4. Client sends login request to the current auth datasource.
5. On success:
   - client stores session;
   - user is navigated to `/garage`.
6. On invalid credentials, show understandable error.

## Session Restore Flow

1. App starts at `/garage`.
2. Router checks `authControllerProvider`.
3. While secure storage is being read, non-auth routes redirect to `/auth`.
4. If a stored token exists, the session is restored and the user continues to `/garage`.
5. If no token exists, the user is redirected to `/login`.

## Yandex ID Auth Flow

Status: future work. There is no Yandex ID UI flow and no backend endpoint in the current MVP scope.

Do not add Yandex ID UI or backend contract details until OAuth and backend integration are explicitly planned.

## Logout Flow

1. User taps logout in settings/profile.
2. Client calls datasource logout with the current refresh token.
3. Client clears secure storage.
4. Auth state becomes unauthenticated.
5. Router redirects the user to `/login`.

## Validation

- Email required.
- Email must be valid.
- Full name required for registration.
- Password required.
- Confirm password required for registration.
- Confirm password must match password.
- Password min length is enforced by the current client and backend as 6 characters.
- Do not submit while request is in progress.

## Empty/Error States

- `/auth` loading state while restoring a session.
- Loading state during submit.
- Field errors for validation.
- Conflict error for existing email.
- Unauthorized error for wrong email/password.
- Generic error for network/server failures.

## Acceptance Criteria

- User can create a backend account with full name, email, and password.
- User is logged in after registration.
- User can log out and log in again.
- Existing stored session is restored on app launch.
- Protected routes redirect unauthenticated users to `/login`.
- Auth routes redirect authenticated users to `/garage`.
- Yandex ID is documented as future work and is not part of the current UI/API scope.

## Demo Credentials

- Login: `driver`
- Password: `password123`

## Mock Error Triggers

- Registering login `existing` shows `Login already exists`.
- Logging in as `network` shows `Network error. Please try again later`.
