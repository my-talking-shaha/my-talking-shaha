# ML Service: Maintenance Prediction

This module estimates how urgently each of 12 vehicle components needs service. The output is a score from **0.0** (all clear) to **1.0** (time to replace).

Detailed scoring rules are in [RULES.md](RULES.md).  
Current coefficients are in [coefficients.json](coefficients.json).

---

## How It Works (short)

1. Take **mileage** and the **date of last maintenance**.
2. Take **vehicle specs**: engine type, displacement, transmission, weight.
3. Each component has a **base interval** (km and months).
4. The interval is adjusted by **coefficients** (diesel, hybrid, automatic, weight, etc.).
5. Compute a mileage score and a time score, then take the **larger** of the two.

The model aims to **warn ~50 km before failure** (alert threshold: score ≥ **0.83**).

---

## API

```bash
pip install -r requirements.txt
uvicorn ml.api:app --reload
```

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| POST | `/api/v1/predict` | Scores for 12 components |

Example request:

```json
{
  "spec": {
    "engine_type": "Бензиновый",
    "displacement": 2.0,
    "transmission": "Автомат",
    "weight": 1500
  },
  "usage": {
    "total_distance_km": 600,
    "average_speed": 60,
    "altitude_gain": 1500,
    "total_trips": 150,
    "median_trip_duration": 25,
    "last_maintenance_date": "2026-06-12T14:30:00"
  }
}
```

You can pass `"modification_id"` instead of a manual `spec` — specs will be loaded from the CSV catalog.

---

## Where the Coefficients Come From

Coefficients were originally **set by hand** (see [RULES.md](RULES.md)).  
Then they were **fine-tuned** on real owner complaints from the **NHTSA** database (USA).

### Data Sources

| Source | What it provides |
|--------|------------------|
| [NHTSA FLAT_CMPL](https://static.nhtsa.gov/odi/ffdd/cmpl/FLAT_CMPL.zip) | Owner complaints with mileage at failure |
| [failure-mileage-distribution](https://huggingface.co/datasets/ProblemsByVin/failure-mileage-distribution) | Median failure mileages (for post-training checks) |
| NHTSA VPIC API | Weight, engine displacement, transmission type (optional, cached) |

Each complaint is mapped to one of our 12 components via the failure description (`COMPDESC`).  
NHTSA vehicle fields are normalized to our `CarSpec` format (fuel type → engine type, etc.).

### Training Set (latest run)

| Parameter | Value |
|-----------|-------|
| Complaints selected | 4,978 |
| Vehicle makes | 60 |
| Make+model combinations | 481 |
| Training points | 11,748 |
| Validation points | 3,186 |

**How the sample was built:** complaints with 1,000–400,000 miles, at most 20 per group (make + model + decade + component), so one popular vehicle does not dominate training. Goal — diversity of makes and components.

### How Training Works

This is **not a neural net from scratch**. We keep the same formula used in code (`effective_interval = base × coefficients`), but the coefficients become **learnable parameters**.

- **Framework:** PyTorch, Adam optimizer
- **What we learn:** multipliers for engine, transmission, weight + a separate `part_scale` for each of the 12 components
- **Loss:** the model should produce score ≥ 0.83 at 50 km before failure, a low score far from failure, and score = 1.0 after failure; plus a penalty if intervals drift too far from prior values

### Metrics (latest run)

| Metric | Value | Notes |
|--------|-------|-------|
| Early-warning recall @ 50 km | **79%** | Share of cases where the alert fired in time |
| False alarm rate | **66%** | Still high — needs more data/epochs |

Details are in [`data/training_report.json`](data/training_report.json).

---

## How to Retrain

```bash
# 1. Download fresh NHTSA complaints (~1.5 GB)
python -m ml.nhtsa_download

# 2. Train coefficients
python -m ml.train --epochs 1000 --max-complaints 20000

# 3. Verify
pytest ml/test_api.py ml/test_coefficients.py
```

After training, [`coefficients.json`](coefficients.json) and [`data/training_report.json`](data/training_report.json) are updated.  
The service picks up the new values on the next start — no API changes needed.

---

## Current Coefficients (rounded)

Values below are from the latest training run. Exact floats are in [`coefficients.json`](coefficients.json).

### Engine

| Condition | Component | × |
|-----------|-----------|---|
| Diesel | fuel_filter, injectors | 0.80 |
| Hybrid | brake_pads, brake_discs | 1.50 |
| Hybrid | engine_oil, oil_filter | 1.15 |
| Electric | brake_pads, brake_discs | 1.60 |
| Electric | tires, suspension | 0.90 |
| Gasoline, ≤1600 cc | spark_plugs | 0.80 |
| Gasoline, ≥3000 cc | spark_plugs | 1.04 |

### Transmission and Weight

| Condition | Component | × |
|-----------|-----------|---|
| Automatic | transmission_oil | 0.78 |
| Automatic | transmission_filter | 0.85 |
| Manual | clutch | 0.90 |
| Manual | transmission_oil | 1.14 |
| Manual | transmission_filter | 1.15 |
| Weight > 2200 kg | brakes, tires, suspension | 0.85 |
| Weight < 1300 kg | brakes, tires, suspension | 1.10 |

### Per-Component Scale (`part_scale`)

| Component | × |
|-----------|---|
| Engine Oil | 0.92 |
| Oil Filter | 1.00 |
| Air Filter | 0.99 |
| Cabin Air Filter | 1.05 |
| Brake Fluid | 0.92 |
| Brake Pads | 0.65 |
| Transmission Fluid | 0.91 |
| Coolant | 1.27 |
| Spark Plugs | 0.86 |
| Battery | 0.95 |
| Tire Rotation | 0.80 |
| Suspension | 0.96 |

---

## Folder Structure

| File | Purpose |
|------|---------|
| `api.py` | FastAPI HTTP server |
| `predict.py` | Score calculation |
| `coefficients.py` | Load and apply coefficients |
| `coefficients.json` | **Current** trained coefficients |
| `train.py` | Training script |
| `nhtsa_download.py` / `nhtsa_parse.py` | Download and parse NHTSA |
| `vehicle_sync.py` | NHTSA → our vehicle format |
| `component_mapping.py` | NHTSA part → one of our 12 |
| `RULES.md` | Logic description (numbers may be stale — check the JSON) |

Raw NHTSA data lives in `data/nhtsa/` and is not committed to git (see `data/.gitignore`).
