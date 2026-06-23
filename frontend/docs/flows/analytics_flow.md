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
