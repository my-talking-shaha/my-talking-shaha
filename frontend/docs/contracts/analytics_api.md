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

## Empty Data

No-data response is still `200`. Totals and metrics are zero, chart arrays are empty or zeroed,
and `hasData` is `false`.

## Errors

- `400 VALIDATION_ERROR` for invalid `period`
- `401 UNAUTHORIZED` after auth is enabled
- `403 FORBIDDEN`
- `404 NOT_FOUND`

## Client Notes

- Backend is the source of truth for aggregates.
- Client formats money, mileage, period labels, and charts.
- Refresh analytics after timeline or parts changes.
