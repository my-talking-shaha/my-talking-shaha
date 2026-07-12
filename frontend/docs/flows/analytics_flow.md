# Analytics Flow

## User Stories

Covers:
- STATUS-03 analysis of technical history, Should. 
- STATUS-04 analytics of expenses and mileage, Should.

## Screens

- Analytics dashboard.
- Period selector: MONTH / YEAR / ALL_TIME.
- Expense categories.
- Mileage chart.
- Repair frequency chart.
- Fuel consumption widget.
- Embedded parts feature widget / maintenance forecast card.

## Analytics Dashboard Flow

1. User opens `/vehicle/:vehicleId/analytics`.
2. Client requests analytics summary for the selected period.
3. Screen displays aggregates, charts, and empty states.
4. User changes period.
5. Client reloads analytics or reads cached analytics for the selected period.

## Metrics

Show when available:
- total expenses;
- expenses by category: repairs, fuel, maintenance, parts;
- monthly/yearly expense chart;
- mileage over time;
- repair count/frequency;
- most frequent repair types;
- average fuel consumption per 100 km;
- cost per km.

## Parts Feature Usage

Analytics can reuse the parts feature widget to show service forecast and remaining part lifetime.

This block should be treated as a reusable UI component from the `parts` feature, not as analytics-owned business logic.

Analytics may display:

- next maintenance forecast;
- most critical parts by remaining lifetime;
- parts with warning or critical status;
- service readiness score if provided by backend.

Analytics must not duplicate complex part lifetime calculation rules if backend already provides calculated values.

## Empty States

Do not fake analytics.

If not enough data:

- show explanation;
- suggest adding refueling, trip, repair, maintenance, or part replacement records.

## Data Ownership

Backend should be the source of truth for aggregates.

Client can:

- format values;
- visualize charts;
- group simple UI sections;
- display backend-provided summaries.

Client should not duplicate complex analytics, prediction, or reliability rules unless explicitly documented.

## Acceptance Criteria

- User can open analytics dashboard.
- User can see expenses by category.
- User can see cost per kilometer and history analysis metrics.
- User can select period.
- User can see empty states when data is insufficient.
- Data updates when new timeline records are added.
- Parts feature widget can be reused inside analytics without moving parts logic into analytics.

## Preserved Interaction Baseline

This section records the behavior that must remain unchanged during UI-only
refactoring.

- The initial summary period is `YEAR`; no custom date range is selected.
- The initial mileage filter is the current year with all months selected.
- Selecting `MONTH`, `YEAR`, or `ALL_TIME` reloads the summary and clears an
  active custom range. It does not change the mileage filters.
- The custom range picker accepts dates from January 1 ten years before the
  current year through today. Its initial range is the previous 30 days or the
  currently selected range. Cancelling preserves the current state; confirming
  reloads the summary; clearing restores the selected period request.
- Mileage years include the current year and four previous years. Selecting a
  month requests daily points; selecting all months requests monthly points.
  Changing the year preserves the selected month.
- Vertical swipes scroll the dashboard in both directions. Horizontal swipes
  have no feature action and must not change period, filters, or navigation.
- Summary loading and failure replace the dashboard. Retry refreshes both the
  current summary and mileage requests. Mileage loading/failure/no-data states
  remain local to the mileage card.
- Analytics summary and mileage data are refreshed every 60 seconds while the
  screen is mounted.
- The parts forecast is rendered only when the parts provider has data;
  loading and failure are hidden.
- Insufficient data replaces the dashboard with actions: trip opens
  `type=trip`, refueling uses the history form default, and repair opens
  `type=maintenance`.
- When opened from chat, the screen has an Analytics app bar whose back action
  navigates to `/vehicle/:vehicleId/chat`. Otherwise analytics supplies no app
  bar of its own.
