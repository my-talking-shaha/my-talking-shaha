# ML Maintenance Prediction

Simple module for predicting car maintenance needs based on specifications and usage.

## Usage

### Option 1: Load specification from CSV

```python
from datetime import datetime, timedelta
from ml.loader import load_car_spec
from ml.models import Usage
from ml.predict import predict

# 1. Load car specification from CSV by modification ID
spec = load_car_spec('10381815__10381823')  # BMW X5 35i xDrive

# 2. Specify usage parameters since last maintenance
usage = Usage(
    total_distance_km=5000,
    average_speed=60,
    altitude_gain=1500,
    total_trips=150,
    median_trip_duration=25,
    last_maintenance_date=datetime.now() - timedelta(days=30)
)

# 3. Get maintenance recommendations
result = predict(spec, usage)
print(f"Urgent services: {result['urgent_count']}/{result['total_components']}")
```

### Option 2: Create specification manually

```python
from datetime import datetime, timedelta
from ml.models import CarSpec, Usage
from ml.predict import predict

# 1. Create car specification
spec = CarSpec(
    engine_type='petrol',
    displacement=2.0,
    transmission='automatic',
    weight=1500
)

# 2. Specify usage parameters
usage = Usage(
    total_distance_km=5000,
    average_speed=60,
    altitude_gain=1500,
    total_trips=150,
    median_trip_duration=25,
    last_maintenance_date=datetime.now() - timedelta(days=30)
)

# 3. Get maintenance recommendations
result = predict(spec, usage)

# Results
print(f"Urgent services: {result['urgent_count']}/{result['total_components']}")
print(f"Services needed: {result['urgent_services']}")

# Details for each component
for component_name, need in result['components'].items():
    if need.needed:
        print(f"🔴 {need.name}: {need.reason}")
```

### List available modifications

```python
from ml.loader import list_modifications

# Show first 10 modifications
mods = list_modifications()
print(mods.head(10))

# Find specific car brand
bmw_x5 = mods[mods['mark_id'] == 'BMW']
print(bmw_x5)
```

## Components and functions

**Data classes:**

- **CarSpec** - car specifications (engine type, displacement, transmission, weight)
- **Usage** - usage parameters (distance, speed, altitude, trips, maintenance date)
- **MaintenanceNeed** - maintenance result for one component

**Functions:**

- **`load_car_spec(modification_id, csv_dir)`** - load specification from CSV
- **`list_modifications(csv_dir)`** - list all available car modifications
- **`predict(spec, usage)`** - get maintenance recommendations

## Logic

For now no ML applied: Maintenance is needed if ONE of these conditions is met:

- Distance >= interval in km (default 3000 km for oil)
- Time >= interval in months (default 6 months for oil)

Component intervals:

- Engine Oil, Oil Filter: 3000 km or 6 months
- Air/Cabin Filters: 15000 km or 12 months
- Brake Pads, Transmission, Coolant: 40000-50000 km or 24 months
- And others...

## `predict()` result

```python
{
    'components': {
        'Engine Oil': MaintenanceNeed(...),
        'Brakes': MaintenanceNeed(...),
        ...
    },
    'urgent_count': 2,              # Number of components needing service
    'urgent_services': ['Engine Oil', 'Brakes'],
    'total_components': 12,
    'analysis_date': '2026-06-22T...'
}
```
