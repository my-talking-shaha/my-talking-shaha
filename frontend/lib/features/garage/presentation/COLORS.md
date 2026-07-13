# Garage color contract

The shipped garage UI uses `GarageColors` as follows:

| Tokens | UI responsibility |
| --- | --- |
| `background`, `backgroundDark`, `surface`, `surfaceHighest`, `border` | empty state, vehicle cards, image/metric tiles and their outlines |
| `formBackground`, `formField`, `formBorder` | add-vehicle screen and input controls |
| `primary`, `formPrimary`, `primaryLight`, `primaryPressed`, `primarySoft` | add actions, submit button, focus states and vehicle image accents |
| `textPrimary`, `textSecondary`, `hint`, `white` | values, supporting text, placeholders and text/icons on accent surfaces |
| `success`, `error` | vehicle-status accent and validation/error state |
| `swipeEdit`, `swipeDelete` | destructive/edit swipe actions |
| `transparent` | transparent form and swipe composition states |

Form-only variants and swipe action colors stay feature-specific unless the same semantic role is adopted elsewhere.
