# Vehicle API Contract

Base path: `/api/v1/vehicles`

Auth: required.

## List Vehicle Brands

`GET /api/v1/vehicles/brands`

Response:

```json
[
  "Abarth",
  "BMW"
]
```

Use this list for brand selection instead of free-text brand entry.

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

`photoUrl` is read-only: it is not accepted in create/update requests and always
reflects the first uploaded photo (or `null`).

## Upload Vehicle Photo

`POST /api/v1/vehicles/{vehicleId}/photos`

Content-Type: `multipart/form-data`

Fields:
- `file`: JPG/PNG, up to 10 MB. Declared content type must match the file content.

Response `201`:

```json
{
  "photoId": "3f2a6c1e-8b4d-4c2a-9f1e-5d7b8a9c0d1f",
  "url": "https://example.com/api/v1/photos/3f2a6c1e-8b4d-4c2a-9f1e-5d7b8a9c0d1f"
}
```

`url` is absolute and requires no auth header, so it can be passed directly to
`Image.network`. Invalid file: `400 VALIDATION_ERROR`.

## List Vehicle Photos

`GET /api/v1/vehicles/{vehicleId}/photos`

Response `200` (ordered by upload time; the first item is the one shown as `photoUrl`):

```json
{
  "photos": [
    {
      "photoId": "3f2a6c1e-8b4d-4c2a-9f1e-5d7b8a9c0d1f",
      "url": "https://example.com/api/v1/photos/3f2a6c1e-8b4d-4c2a-9f1e-5d7b8a9c0d1f"
    }
  ]
}
```

Use this list for the photo gallery with swiping.

## Delete Vehicle Photo

`DELETE /api/v1/vehicles/{vehicleId}/photos/{photoId}`

Response `204`. Replacing a photo is a delete followed by an upload.

## Client Notes

- Dashboard must not invent sensor values.
- If status summary is missing, show `unknown` state.
- Recent events should show latest 5 items when backend provides them.
