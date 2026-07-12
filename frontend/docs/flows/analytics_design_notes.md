# Analytics Design Notes

## Screen From Design

- Accord to `docs/design/screenshots/01_analytics.jpg` for design example

## Visual Structure

The analytics screen is labeled as an intelligence/dashboard screen.

Sections:
1. Header/title `Intelligence`.
2. Screen title `Analytics` and subtitle.
3. Annual/period expenses summary card.
4. Monthly expenses chart card.
5. Embedded parts feature widget / maintenance forecast card.
6. History analysis card with chart and summary metrics.
7. Bottom navigation.

## Expense Summary Card

Displays:
- total annual/period expenses;
- category values: repair, fuel, maintenance, parts;
- cost per km;
- small trend badge.

## Charts

Charts should use:
- dark chart card background;
- muted grid lines;
- cyan/lavender bars or lines;
- minimal labels;
- no random colors.

## Parts Widget Reuse

The analytics screen reuses `MaintenanceForecastCard` from the `parts` feature.
Analytics must not duplicate parts business logic.

## Empty States

Do not fake analytics.
If not enough data exists, show a helpful empty state and suggest adding history records.

## Implementation Notes

- Use `AnalyticsSummaryCard`, `ChartCard`, `PeriodSelector`, `HistoryAnalysisCard`, and `MaintenanceForecastCard`.
- Backend should be the source of truth for aggregates.
- Client can format and visualize values.

## Preserved Color Contract

All analytics-owned color references live in
`lib/features/analytics/presentation/colors.dart`. The refactoring baseline is:

| Token | ARGB / hex |
| --- | --- |
| `background` | `#10131A` |
| `backgroundDark` | `#0E1118` |
| `surface` | `#191A21` |
| `surfaceHigh` | `#1C1F25` |
| `border` | `#2B303B` |
| `primaryLight` | `#B8C3FF` |
| `textPrimary` | `#F4F7FF` |
| `textSecondary` | `#9AA3B2` |
| `textMuted` | `#6F7788` |
| `success` | `#00DCE5` |
| `warning` | `#E8B950` |
| `transparent` | `#00000000` |

The trend badge and line fill use success at 10% opacity, chart grid lines use
border at 60%, and chart bars use their accent at 72%. Dashboard cards preserve
the `surfaceHigh -> surface -> backgroundDark` top-left to bottom-right
gradient, a border, and a 12 px radius.

Layout invariants: page padding is 20 px horizontally, 16 px at the top, and
32 px at the bottom; standard charts are 160 px high and the history chart is
128 px high. Expense categories switch to one column below 300 px, mileage
filters stack below 360 px, and history metrics switch to one column below
310 px.
