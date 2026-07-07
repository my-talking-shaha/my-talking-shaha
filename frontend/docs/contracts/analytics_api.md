# Analytics API Contract

Base path: `/api/v1/vehicles/{vehicleId}/analytics`

Auth: required.

## Get Analytics Overview

`GET /api/v1/vehicles/{vehicleId}/analytics?period=MONTH`

Period values:

```text
MONTH
YEAR
ALL_TIME
```

Custom range:

```text
GET /api/v1/vehicles/{vehicleId}/analytics?startDate=2026-01-01&endDate=2026-06-30
```

`startDate` and `endDate` are inclusive ISO dates and must be provided together.
When a custom range is selected, the client sends both dates and uses the response
to update every analytics card/chart.

Response:

```json
{
  "period": "YEAR",
  "totalExpenses": 342500,
  "currency": "RUB",
  "expensesByCategory": {
    "FUEL": 112500,
    "MAINTENANCE": 56000,
    "PARTS": 174000
  },
  "monthlyExpenses": [
    {
      "month": "2026-06",
      "total": 15650,
      "breakdownByCategory": {
        "FUEL": 2450,
        "MAINTENANCE": 8900,
        "PARTS": 4300
      }
    }
  ],
  "seasonalExpenses": [
    { "season": "SUMMER", "total": 15650 }
  ],
  "costPerKilometer": {
    "totalKm": 1240,
    "totalExpenses": 15650,
    "costPerKm": 12.62
  },
  "fuel": {
    "totalLiters": 120.4,
    "averageConsumptionLitersPer100Km": 7.2
  },
  "historyAnalysis": {
    "eventCount": 7,
    "refuelCount": 2,
    "tripCount": 1,
    "maintenanceCount": 3,
    "partEventCount": 1,
    "totalTripKm": 1240,
    "averageTripKm": 1240
  },
  "hasData": true
}
```

## Get Mileage Trend

`GET /api/v1/vehicles/{vehicleId}/analytics/mileage-trend?year=2026&month=6`

`year` is required. `month` is optional and must be a number from `1` to `12`.
When `month` is omitted, the response is a yearly mileage trend grouped by
month. When `month` is provided, the response contains points inside that
calendar month.

Response:

```json
{
  "year": 2026,
  "month": 6,
  "points": [
    { "label": "Jun 1", "mileageKm": 142000 },
    { "label": "Jun 15", "mileageKm": 143240 },
    { "label": "Jun 30", "mileageKm": 145180 }
  ],
  "hasData": true
}
```

For a yearly trend, `month` is `null` or omitted and point labels should be
short month labels such as `Jan`, `Feb`, `Mar`.

No-data response is still `200` with `points = []` and `hasData = false`.

## Empty Data

No-data response is still `200`. Totals and metrics are zero, chart arrays are empty or zeroed,
and `hasData` is `false`.

## Errors

- `400 VALIDATION_ERROR` for invalid `period`
- `400 VALIDATION_ERROR` when only one custom date is provided or `startDate` is after `endDate`
- `400 VALIDATION_ERROR` for missing `year` or invalid `month` in mileage trend requests
- `401 UNAUTHORIZED` after auth is enabled
- `403 FORBIDDEN`
- `404 NOT_FOUND`

## Client Notes

- Backend is the source of truth for aggregates.
- Client formats money, mileage, period labels, and charts.
- Client requests mileage trend with `year` and optional `month`; it does not aggregate mileage locally.
- Refresh analytics after timeline or parts changes.
