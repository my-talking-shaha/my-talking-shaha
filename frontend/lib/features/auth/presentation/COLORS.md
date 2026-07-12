# Auth color contract

The shipped authentication UI uses `AuthColors` as follows:

| Tokens | UI responsibility |
| --- | --- |
| `background` | login and registration screen background |
| `surface`, `formBorder`, `black` | form card fill, outline and shadow |
| `surfaceHigh`, `border`, `primary`, `white` | login/register mode selector states |
| `primaryLight` | brand title and focused form controls |
| `textPrimary`, `textSecondary` | error/content text and supporting/auth prompt copy |
| `error` | authentication error banner |

Unused palette members remain baseline values, but tests should pin the tokens above because they are connected to rendered components.
