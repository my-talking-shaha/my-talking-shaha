# History color contract

The shipped history UI uses `HistoryColors` as follows:

| Tokens | UI responsibility |
| --- | --- |
| `background`, `surface`, `surfaceElevated`, `border` | timeline/form backgrounds, event cards, fields and outlines |
| `primary`, `primarySoft`, `primaryPressed`, `onPrimary` | filters, add action, selected controls and foreground on the add action |
| `textPrimary`, `textSecondary`, `textMuted`, `white` | event/form content, metadata and text on colored controls |
| `warning`, `error`, `destructive` | event category, validation and delete action |
| `transparent` | unselected filter state |

The brighter history `primary` and its `onPrimary` foreground are intentional component roles, not interchangeable names.
