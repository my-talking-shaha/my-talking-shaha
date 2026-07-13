# Parts color contract

The shipped parts UI uses `PartsColors` as follows:

| Tokens | UI responsibility |
| --- | --- |
| `cardBackground`, `border` | maintenance forecast and async-state cards |
| `headerText`, `headerTextMuted`, `bodyText`, `bodyTextMuted` | forecast headings, values and supporting copy |
| `progressTrack` | remaining-resource progress track |
| `badgeBackground`, `badgeBorder`, `warning` | warning badge surface, outline and foreground |
| `ok`, `warning`, `critical`, `unknown` | remaining-resource semantic levels |
| `accent` | retry/action accent in async states |
| `error` | parts loading/error state |

The parts typography shades and badge colors are intentionally feature-specific; only identical shared border/error values should be centralized initially.
