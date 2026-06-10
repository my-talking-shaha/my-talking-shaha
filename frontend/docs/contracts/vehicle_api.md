# Vehicle API Contract

Base path: `/api/v1/vehicles`

Auth: required.

## Get Vehicle Dashboard

`GET /api/v1/vehicles/{vehicleId}`

Response:

```json
{
  "id": "vehicle_123",
  "brand": "Lada",
  "model": "2106",
  "year": 1998,
  "color": "blue",
  "vin": "XTA2106001234567",
  "currentMileageKm": 124580,
  "engine": {
    "type": "gasoline",
    "volumeLiters": 1.6
  },
  "photoUrl": "https://example.com/photo.jpg",
  "statusSummary": {
    "status": "ok",
    "lastMaintenanceDate": "2026-06-01T09:15:00Z",
    "activeWarningsCount": 0,
    "message": "Шаха готова к выезду"
  },
  "recentEvents": [
    {
      "id": "event_1",
      "type": "trip",
      "title": "Завершена поездка",
      "subtitle": "Дом → Работа · 12.4 км",
      "occurredAt": "2026-06-10T14:20:00Z"
    }
  ]
}
```

Status values:

```text
ok
warning
critical
unknown
```

## Update Vehicle

`PATCH /api/v1/vehicles/{vehicleId}`

Request example:

```json
{
  "color": "dark blue",
  "vin": "XTA2106001234567",
  "currentMileageKm": 125000
}
```

Response: updated vehicle dashboard object or basic vehicle object.

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
