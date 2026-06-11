# Analytics Design Notes

## Screen From Design

- Accord to `docs/design/screenshots/01_analytics.jpg` for design example

## Visual Structure

The analytics screen is labeled as an intelligence/dashboard screen.

Sections:
1. Header/title `Intelligence`.
2. Screen title `Аналитика` and subtitle.
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
