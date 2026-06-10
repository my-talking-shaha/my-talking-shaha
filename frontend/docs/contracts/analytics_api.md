# Analytics API Contract

Base path: `/api/v1/vehicles/{vehicleId}/analytics`

Auth: required.

## Get Analytics Summary

`GET /api/v1/vehicles/{vehicleId}/analytics?period=month`

Period values:

```text
month
year
all
```

Response:

```json
{
  "period": "month",
  "totalExpenses": { "amount": 15650, "currency": "RUB" },
  "expensesByCategory": [
    { "category": "fuel", "amount": 2450 },
    { "category": "repair", "amount": 8900 },
    { "category": "maintenance", "amount": 4300 }
  ],
  "mileage": {
    "totalKm": 1240,
    "costPerKm": 12.62
  },
  "fuel": {
    "averageConsumptionPer100Km": 7.2,
    "totalLiters": 120.4
  },
  "repairs": {
    "count": 3,
    "mostFrequentTypes": ["oil", "brakes"]
  },
  "charts": {
    "expensesByMonth": [
      { "label": "May", "amount": 15650 }
    ],
    "mileageByMonth": [
      { "label": "May", "km": 1240 }
    ]
  },
  "hasEnoughData": true
}
```

## Empty/Insufficient Data

Response:

```json
{
  "period": "month",
  "hasEnoughData": false,
  "message": "Недостаточно данных для аналитики"
}
```

Client must not fabricate charts or metrics.

## Categories

```text
fuel
repair
maintenance
parts
washing
other
```

## Client Notes

- Backend is source of truth for aggregates.
- Client formats money, mileage, and charts.
- Refresh analytics after timeline changes.
