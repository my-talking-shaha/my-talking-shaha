# Analytics Flow

## User Stories

Covers:
- STATUS-03 analysis of technical history, Should.
- STATUS-04 analytics of expenses and mileage, Should.

## Screens

- Analytics dashboard.
- Period selector: month / year / all time.
- Expense categories.
- Mileage chart.
- Repair frequency chart.
- Fuel consumption widget.

## Analytics Dashboard Flow

1. User opens `/vehicle/:vehicleId/analytics`.
2. Client requests analytics summary for selected period.
3. Screen displays aggregates, charts, and empty states.
4. User changes period.
5. Client reloads or reads cached analytics for new period.

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

## Empty States

Do not fake analytics.

If not enough data:
- show explanation;
- suggest adding refueling, trip, repair, or maintenance records.

## Data Ownership

Backend should be source of truth for aggregates. Client can format and visualize but should not duplicate complex analytics rules unless explicitly documented.

## Acceptance Criteria

- User can open history analysis.
- User can see expenses by category.
- User can see mileage dynamics.
- User can select period.
- Data updates when new timeline records are added.
