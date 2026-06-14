# Garage API Contract

Base path: `/api/v1/garage`

Auth: required.

## Get Garage Vehicles

`GET /api/v1/garage/vehicles`

Response `200`:

```json
{
  "vehicles": [
    {
      "id": "vehicle_123",
      "brand": "Lada",
      "model": "2106",
      "year": 1998,
      "color": "blue",
      "currentMileageKm": 124580,
      "engineType": "gasoline",
      "photoUrl": "https://example.com/photo.jpg",
      "status": "ok",
      "activeWarningsCount": 0
    }
  ]
}
```

Empty garage:

```json
{
  "vehicles": []
}
```

## Create Vehicle

`POST /api/v1/garage/vehicles`

Request:

```json
{
  "brand": "Lada",
  "model": "2106",
  "year": 1998,
  "color": "blue",
  "currentMileageKm": 124580,
  "engineType": "gasoline"
}
```

Response `201`:

```json
{
  "id": "vehicle_123",
  "brand": "Lada",
  "model": "2106",
  "year": 1998,
  "color": "blue",
  "currentMileageKm": 124580,
  "engineType": "gasoline",
  "photoUrl": null,
  "status": "unknown",
  "activeWarningsCount": 0
}
```

Validation:
- brand required;
- model required;
- year required;
- currentMileageKm >= 0;
- engineType required;
- color optional.

## Delete Vehicle

`DELETE /api/v1/garage/vehicles/{vehicleId}`

Response `204`.

Client must ask for confirmation before calling delete.

## Vehicle Catalog

Priority: optional.

`GET /api/v1/garage/catalog?query=lada`

Response:

```json
{
  "items": [
    { "brand": "Lada", "model": "2106" }
  ]
}
```
