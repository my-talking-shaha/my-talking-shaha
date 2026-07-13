# Settings color contract

The shipped settings UI uses `SettingsColors` as follows:

| Tokens | UI responsibility |
| --- | --- |
| `surface`, `surfaceHighest`, `border` | profile card, settings cards and segmented controls |
| `primary`, `primaryLight`, `white` | avatar, selected theme segment and profile accent |
| `textPrimary`, `textSecondary`, `textMuted` | tile titles, section labels, choices and navigation icon |
| `transparent` | unselected theme segment |

These shared semantic roles should follow the active application theme so the settings screen can safely control light/dark mode.
