# Dashboard color contract

The shipped dashboard UI uses `DashboardColors` as follows:

| Tokens | UI responsibility |
| --- | --- |
| `surface`, `surfaceHighest`, `border` | dashboard cards and neutral event icon backgrounds |
| `primaryLight`, `success`, `warning` | primary highlights and event/status categories |
| `textSecondary`, `textMuted`, `textDisabled` | labels, VIN metadata and disabled copy action |
| `heroOverlay`, `heroGradientStart`, `heroGradientMiddle`, `heroGradientEnd` | vehicle hero image overlay and background gradient |
| `fuelEventBackground`, `maintenanceEventBackground` | semantic recent-event icon backgrounds |
| `transparent` | hero image fallback/overlay composition |

Generic surface, border, text and semantic values may be shared; hero and event-background values are dashboard-specific.
