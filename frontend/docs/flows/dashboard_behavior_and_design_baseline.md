# Dashboard Behavior and Design Baseline

This document records the dashboard behavior and visual contract that existed
before the presentation refactor. The baseline was captured from commit
`089266d148abb32cea681672c959599f42d37e18`.

## Interaction and State Contract

- Opening `/vehicle/:vehicleId/dashboard` watches an auto-disposed, vehicle-ID
  scoped future provider.
- While loading, the screen shows a centered circular progress indicator.
- A successful load shows one vertically scrollable list. There are no forms,
  horizontal carousels, pull-to-refresh gestures, or swipe actions in this
  feature.
- The default back action opens `/garage`. When the dashboard was launched from
  chat, it opens `/vehicle/:vehicleId/chat` instead.
- `View all` opens `/vehicle/:vehicleId/history`.
- A load failure shows the unavailable state. `Retry` refreshes the same
  vehicle-scoped provider.
- The bottom navigation belongs to the application navigation shell, not to the
  dashboard screen.

## Vehicle Summary Contract

- The hero is 252 px high. A non-blank photo URL is rendered with `BoxFit.cover`.
- A missing, blank, or failed network photo uses the three-color gradient and
  car SVG fallback. The dark title overlay is always present.
- Brand and model are shown on at most two lines with ellipsis overflow.
- Mileage uses comma-separated thousands and the `km` suffix.
- Engine power has priority over volume. With no power, volume is shown without
  a trailing `.0`; with neither value, the literal `Unknown` is shown.
- `gasoline`, `diesel`, `hybrid`, `phev`, and `electric` engine types are
  localized. Any other value is displayed unchanged.
- VIN is trimmed. A missing or blank VIN shows the localized unavailable label
  and disables copy. A valid VIN is copied to the platform clipboard, the
  previous snackbar is hidden, and the localized success snackbar is shown.

## Maintenance and Event Contract

- The parts-owned `MaintenanceForecastCard` receives the dashboard parts list
  unchanged. Dashboard does not reorder, filter, or reinterpret it.
- An empty events list shows the localized empty card.
- Every supplied recent event is displayed in input order. Dashboard itself
  does not sort or truncate the list.
- Fuel, maintenance, and trip events retain their distinct SVG assets and
  colors.
- Today's event shows a 24-hour time. An event from exactly the previous
  calendar day uses the uppercase localized medium date. Other dates use the
  uppercase localized short month/day. This deliberately records the existing
  behavior rather than changing it to a `Yesterday` label.
- Event tiles are informational and have no tap or swipe action.

## Layout Contract

- List padding: 20 px left/right, 16 px top, and 32 px bottom.
- Order: vehicle hero, metric cards, VIN, maintenance forecast, recent events.
- Metric cards are 132 px high and use equal horizontal space.
- Dashboard-owned cards use a 12 px radius, `surface` background, and a 1 px
  `border` outline.

## Dashboard Palette

All dashboard-owned presentation colors are centralized in
`lib/features/dashboard/presentation/colors.dart`.

| Token | ARGB |
| --- | --- |
| `background` | `0xFF10131A` |
| `primary` | `0xFF2E5BFF` |
| `primaryLight` | `0xFFB8C3FF` |
| `surface` | `0xFF1C1F25` |
| `surfaceHighest` | `0xFF232731` |
| `border` | `0xFF2B303B` |
| `textPrimary` | `0xFFF4F7FF` |
| `textSecondary` | `0xFF9AA3B2` |
| `textMuted` | `0xFF6F7788` |
| `textDisabled` | `0xFF4B5263` |
| `success` | `0xFF00DCE5` |
| `warning` | `0xFFE8B950` |
| `transparent` | `0x00000000` |
| `heroOverlay` | `0xE610131A` |
| `heroGradientStart` | `0xFF102B3B` |
| `heroGradientMiddle` | `0xFF131B31` |
| `heroGradientEnd` | `0xFF10131A` |
| `fuelEventBackground` | `0xFF30291F` |
| `maintenanceEventBackground` | `0xFF123138` |

The embedded maintenance card belongs to the `parts` feature, so its internal
colors remain centralized in that feature's `parts_design_tokens.dart`. Moving
those tokens into dashboard would reverse the intended feature ownership.
