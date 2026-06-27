# Vehicle Maintenance Prediction Rules

## Purpose

The goal of the maintenance prediction model is to estimate the probability that a vehicle component requires maintenance based on:

* current mileage;
* time since last maintenance;
* vehicle technical specifications;
* known maintenance intervals for the component.

The model intentionally produces a **maintenance need score** rather than a binary decision. This allows downstream systems to rank recommendations and define their own thresholds.

---

# Core Principle

Every component has a nominal maintenance interval:

```python
(km_interval, month_interval)
```

Example:

```python
engine_oil = (15000 km, 12 months)
brake_fluid = (0 km, 24 months)
spark_plugs = (60000 km, 48 months)
```

The prediction model compares the actual vehicle usage against these intervals.

---

# Mileage-Based Wear

For mileage-dependent components we compute:

```python
mileage_ratio = current_mileage_since_service / effective_km_interval
```

Interpretation:

| Ratio     | Meaning                           |
| --------- | --------------------------------- |
| < 0.6     | Component is far from maintenance |
| 0.6 - 1.0 | Approaching maintenance           |
| 1.0       | Maintenance is due                |
| > 1.2     | Maintenance is overdue            |

The score is normalized to:

```python
0.0 ... 1.0
```

using linear interpolation.

Example:

```text
Interval = 15 000 km
Current mileage = 12 000 km

ratio = 12000 / 15000 = 0.8

maintenance_need ≈ 0.33
```

---

# Time-Based Wear

Some components degrade even when mileage is low.

Examples:

* brake fluid;
* coolant;
* engine oil;
* battery;
* cabin filters.

For such components:

```python
time_ratio = days_since_service / target_days
```

where

```python
target_days = month_interval * 30
```

The same normalization strategy is applied.

---

# Combining Mileage and Time

The model uses the higher risk:

```python
score = max(
    mileage_score,
    time_score
)
```

Rationale:

A component requiring replacement because of age should not receive a low score simply because the vehicle was rarely driven.

Example:

```text
Engine oil

Mileage score = 0.10
Time score = 0.95

Result = 0.95
```

---

# Effective Maintenance Interval

The nominal maintenance interval can be adjusted based on vehicle specifications.

The model calculates:

```python
effective_interval =
    base_interval
    * engine_factor
    * transmission_factor
    * weight_factor
```

Lower interval means faster wear.

Higher interval means slower wear.

---

# Engine Type Rules

## Gasoline Engine

Baseline configuration.

No global adjustments are applied.

### Spark Plugs

Small-displacement gasoline engines often use turbocharging and higher cylinder pressures.

Rule:

```python
displacement <= 1600 cc
```

```python
spark_plug_interval *= 0.8
```

Reason:

Spark plugs experience higher thermal and ignition stress.

---

## Diesel Engine

Diesel fuel systems operate under extremely high pressure and are more sensitive to fuel contamination.

Rules:

```python
fuel_filter *= 0.8
injectors *= 0.8
```

Reason:

Fuel quality has a larger impact on diesel systems.

---

## Hybrid Vehicle

Hybrid vehicles reduce usage of several conventional components.

### Brakes

Rule:

```python
brake_pads *= 1.5
brake_discs *= 1.5
```

Reason:

Regenerative braking significantly reduces friction brake usage.

### Engine Oil

Rule:

```python
engine_oil *= 1.15
oil_filter *= 1.15
```

Reason:

The internal combustion engine operates fewer hours than in a conventional vehicle.

---

## Electric Vehicle

Electric vehicles do not contain many ICE-related components.

The following components are considered non-applicable:

```python
engine_oil
oil_filter
spark_plugs
fuel_filter
injectors
timing_belt
```

Maintenance score:

```python
0.0
```

### Brakes

Rule:

```python
brake_pads *= 1.6
brake_discs *= 1.6
```

Reason:

Heavy use of regenerative braking.

### Tires

Rule:

```python
tires *= 0.9
```

Reason:

EVs are typically heavier and generate high instant torque.

### Suspension

Rule:

```python
suspension *= 0.9
```

Reason:

Additional battery weight increases suspension load.

---

# Transmission Rules

## Automatic Transmission

Automatic transmissions contain hydraulic systems, clutches, valve bodies and torque converters.

Rule:

```python
transmission_oil *= 0.85
transmission_filter *= 0.85
```

Reason:

Fluid condition strongly affects transmission lifespan.

---

## Manual Transmission

Manual transmissions are mechanically simpler.

Rule:

```python
transmission_oil *= 1.15
```

Reason:

Lower thermal load and simpler lubrication requirements.

### Clutch

Rule:

```python
clutch *= 0.9
```
