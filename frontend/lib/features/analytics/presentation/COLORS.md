# Analytics color contract

The shipped analytics UI uses `AnalyticsColors` as follows:

| Tokens | UI responsibility |
| --- | --- |
| `background`, `backgroundDark` | screen/filter background and compact metric tiles |
| `surface`, `surfaceHigh`, `border` | cards, filters, charts, loading/error containers and outlines |
| `primaryLight` | selected filters, chart line/points, leading icons and emphasized values |
| `success` | positive totals, mileage/history indicators and chart series |
| `warning` | maintenance/history warning indicators |
| `textPrimary`, `textSecondary`, `textMuted` | card values, supporting labels and subdued metadata |
| `transparent` | unselected filter fill |

These mappings are the visual regression contract for the feature. Shared semantic tokens may be supplied by the application theme, but their role in analytics must remain unchanged.
