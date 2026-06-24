# Vehicle API Contract

Base path: `/api/v1/vehicles`

Auth: required.

## Get Vehicle Dashboard

`GET /api/v1/vehicles/{vehicleId}/dashboard`

Response:

```json
{
  "vehicle": {
    "id": "vehicle_123",
    "brand": "Lada",
    "model": "2106",
    "productionYear": 1998,
    "color": "blue",
    "vin": "XTA21060012345678",
    "mileageKm": 124580,
    "fuelType": "GASOLINE",
    "engineDescription": "1.6 L",
    "photoUrl": null
  },
  "maintenanceForecast": {
    "overallStatus": "OK",
    "nextServiceInKm": 7500,
    "updatedAt": "2026-06-18T17:00:00Z",
    "parts": []
  },
  "recentEvents": []
}
```

Status values:

```text
OK
ATTENTION
CRITICAL
UNKNOWN
```

## Update Vehicle

`PATCH /api/v1/vehicles/{vehicleId}`

Request example:

```json
{
  "color": "dark blue",
  "vin": "XTA21060012345678",
  "mileageKm": 125000,
  "engineDescription": "1.6 L"
}
```

Response: basic vehicle object.

Backend stores engine details in `engineDescription`.

## Upload Vehicle Photo

Priority: Could.

`POST /api/v1/vehicles/{vehicleId}/photos`

Content-Type: `multipart/form-data`

Fields:
- `file`: JPG/PNG.

Response:

```json
{
  "photoId": "photo_123",
  "url": "https://example.com/photo.jpg"
}
```

## Client Notes

- Dashboard must not invent sensor values.
- If status summary is missing, show `unknown` state.
- Recent events should show latest 5 items when backend provides them.
