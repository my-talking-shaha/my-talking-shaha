# Profile and Settings Flow

## Purpose

Profile and settings is a secondary feature that centralizes account identity,
preference controls, notification entry points, and account-level actions.

The profile screen is not a vehicle profile. It represents the signed-in user.
Vehicle-specific profile data belongs to the vehicle/dashboard flows.

## Screens

- Profile/settings screen at `/settings`.
- Profile header section.
- Notification preference row.
- All notifications entry point.
- Theme preference.
- Localization preference.
- Logout action.

## Flow

1. User opens settings from bottom navigation.
2. User sees profile info: avatar or initials, display name, and email.
3. User can review account-related rows such as privacy, security, and support when they are in scope.
4. User can enable or disable notifications.
5. User can open the notification center from the profile/settings screen.
6. User can change theme/localization if supported.
7. User can log out.

## Profile Data

Profile data should come from the authenticated user response:

- user id;
- display name;
- email;
- optional avatar URL.

If editable profile fields are added later, keep them separate from local display
preferences. Editing name, email, avatar, or password should be covered by an
account/profile API, not by the generic settings contract.

## Preferences

Initial MVP can support placeholders or local-only settings for:

- theme: system/dark/light;
- language: ru/en;
- notifications enabled.

Do not build complex account management unless requested. Read-only profile
display is enough for MVP if editing is not explicitly in scope.

## Notifications Entry Point

The profile/settings screen should expose:

- a notification enabled toggle;
- a row or action that opens `/notifications`;
- unread count or latest warning indicator only if the notifications API
  provides it.

The toggle controls notification delivery preference. It should not hide the
notification history screen; users should still be able to review previously
received notifications.

## Logout

1. User taps logout.
2. Confirmation may be shown.
3. Client clears session.
4. App navigates to login.

## Acceptance Criteria

- Settings/profile screen exists if navigation includes it.
- Profile header shows signed-in user identity.
- User can log out.
- User can open notification center from profile/settings.
- Notification toggle exists when notification preferences are implemented.
- Theme/localization controls do not break app layout.
