# Auth Flow

## User Stories

Covers:
- ACC-01 Registration with email/password.
- ACC-02 Yandex ID auth, optional/Should.

## Screens

- Login screen.
- Registration screen.
- Optional forgot password link placeholder.

## Registration Flow

1. User opens registration screen.
2. User enters email and password.
3. Client validates required fields and password length >= 6.
4. Client sends registration request.
5. On success:
   - backend creates user;
   - backend creates empty garage;
   - backend returns session;
   - client stores session;
   - user is navigated to `/garage`.
6. If email already exists, show conflict error.

## Login Flow

1. User opens login screen.
2. User enters email and password.
3. Client validates required fields.
4. Client sends login request.
5. On success:
   - client stores session;
   - user is navigated to `/garage`.
6. On invalid credentials, show understandable error.

## YandexID Auth Flow

Priority: Should.

1. User taps `Войти через YandexID`.
2. Native/web YandexID OAuth flow opens.
3. Client sends YandexID ID token to backend.
4. Backend creates account if needed or returns existing account.
5. Client stores session and navigates to `/garage`.

Do not implement YandexID auth before email/password unless explicitly requested.

## Logout Flow

1. User taps logout in settings/profile.
2. Client calls logout if backend supports it.
3. Client clears token/session storage.
4. User navigates to `/auth/login`.

## Validation

- Email required.
- Password required.
- Password min length: 6 for registration.
- Do not submit while request is in progress.

## Empty/Error States

- Loading state during submit.
- Field errors for validation.
- Conflict error for existing email.
- Generic error for network/server failures.

## Acceptance Criteria

- User can create account with email/password.
- Empty garage exists after registration.
- User is logged in after registration.
- User can log out and log in again.
- YandexID auth button exists only if feature is in scope.
