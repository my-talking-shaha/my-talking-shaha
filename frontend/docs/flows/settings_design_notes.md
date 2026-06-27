# Profile and Settings Design Notes

## Screen From Design

- Accord to `docs/design/screenshots/01_settings.jpg` for design example

## Visual Structure

The profile/settings screen is a grouped settings page with a profile header.
The profile header is the primary identity anchor for the signed-in user.

Sections:
- user/profile card with avatar or initials, display name, and email;
- account settings;
- preferences;
- notifications toggle;
- all notifications row;
- about/app information;
- logout action.

## Component Structure

Use:

- `ProfileHeaderCard`;
- `SettingsSection`;
- `SettingsTile`;
- switches/toggles for boolean settings;
- destructive styling for logout only.

## Profile Header Content

Display:

- avatar image when available;
- initials fallback when no avatar is available;
- display name;
- email;
- optional account status only if provided by backend.

Avoid vehicle details, garage data, or maintenance state in the user profile
header. Those belong to vehicle/dashboard screens.

## Implementation Notes

- Keep settings simple for MVP.
- Theme and localization can be UI-only placeholders until persistence exists.
- Profile data should be read from the authenticated user/session source.
- Notification toggle should connect to real notification preferences when
  backend/local settings are ready.
- The "All notifications" row should navigate to `/notifications`.
