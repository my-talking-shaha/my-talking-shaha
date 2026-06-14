# Settings Design Notes

## Screen From Design

- Accord to `docs/design/screenshots/01_settings.jpg` for design example

## Visual Structure

The settings screen is a grouped settings page with a profile header.

Sections:
- user/profile card;
- account settings;
- preferences;
- notifications toggle;
- about/app information;
- logout action.

## Component Structure

Use:
- `ProfileHeaderCard`;
- `SettingsSection`;
- `SettingsTile`;
- switches/toggles for boolean settings;
- destructive styling for logout only.

## Implementation Notes

- Keep settings simple for MVP.
- Theme and localization can be UI-only placeholders until persistence exists.
- Notification toggle should connect to real notification preferences only when backend/local settings are ready.
