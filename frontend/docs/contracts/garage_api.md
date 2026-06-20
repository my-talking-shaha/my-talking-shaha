# Garage API Contract

Base path: `/api/v1/vehicles`

Auth: required.

## Get Garage Vehicles

`GET /api/v1/vehicles`

Response `200`:

```json
[
  {
    "id": "vehicle_123",
    "brand": "Lada",
    "model": "2106",
    "productionYear": 1998,
    "color": "blue",
    "mileageKm": 124580,
    "fuelType": "GASOLINE",
    "engineDescription": "1.6 L",
    "vin": "XTA21060012345678",
    "photoUrl": null
  }
]
```

Empty garage:

```json
[]
```

## Create Vehicle

`POST /api/v1/vehicles`

Request:

```json
{
  "brand": "Lada",
  "model": "2106",
  "productionYear": 1998,
  "color": "blue",
  "mileageKm": 124580,
  "fuelType": "GASOLINE",
  "engineDescription": "1.6 L",
  "vin": "XTA21060012345678"
}
```

Response `201`:

```json
{
  "id": "vehicle_123",
  "brand": "Lada",
  "model": "2106",
  "productionYear": 1998,
  "color": "blue",
  "mileageKm": 124580,
  "fuelType": "GASOLINE",
  "engineDescription": "1.6 L",
  "vin": "XTA21060012345678",
  "photoUrl": null
}
```

Validation:
- brand required;
- model required;
- productionYear required;
- mileageKm >= 0;
- fuelType required;
- color optional;
- VIN optional, exactly 17 symbols if provided.

## Delete Vehicle

`DELETE /api/v1/vehicles/{vehicleId}`

Response `204`.

Client must ask for confirmation before calling delete.

## Vehicle Catalog

Priority: optional.

`GET /api/v1/vehicles/catalog?query=lada`

Response:

```json
{
  "items": [
    { "brand": "Lada", "model": "2106" }
  ]
}
```
