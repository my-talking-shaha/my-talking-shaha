"""Maintenance prediction: CSV loader, predict()."""

from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

import pandas as pd

from ml.coefficients import load_coefficients, need_score as coefficient_need_score
from ml.models import CarSpec, MaintenanceNeed, Usage
from ml.spec_utils import normalize_displacement_cc

COMPONENT_INTERVALS = {
    'Engine Oil': (3000, 6),
    'Oil Filter': (3000, 6),
    'Air Filter': (15000, 12),
    'Cabin Air Filter': (15000, 12),
    'Brake Fluid': (40000, 24),
    'Brake Pads': (50000, 24),
    'Transmission Fluid': (40000, 24),
    'Coolant': (40000, 24),
    'Spark Plugs': (30000, 12),
    'Battery': (10000, 12),
    'Tire Rotation': (10000, 6),
    'Suspension': (20000, 12),
}


def load_car_spec(modification_id: str, csv_dir: Optional[str] = None) -> CarSpec:
    csv_dir = Path(csv_dir) if csv_dir else Path(__file__).parent.parent / "cars" / "csv"
    specs_df = pd.read_csv(csv_dir / "specifications.csv", low_memory=False)
    row = specs_df[specs_df["id"] == modification_id]

    if row.empty:
        raise ValueError(f"Specification not found for modification ID: {modification_id}")

    row = row.iloc[0]
    return CarSpec(
        engine_type=str(row["engine_type"]) if pd.notna(row["engine_type"]) else "unknown",
        displacement=float(row["displacement"]) if pd.notna(row["displacement"]) else None,
        transmission=str(row["transmission"]) if pd.notna(row["transmission"]) else "unknown",
        weight=float(row["weight"]) if pd.notna(row["weight"]) else 0.0,
    )


def list_modifications(csv_dir: Optional[str] = None) -> pd.DataFrame:
    csv_dir = Path(csv_dir) if csv_dir else Path(__file__).parent.parent / "cars" / "csv"
    return pd.read_csv(csv_dir / "modifications.csv")[["id", "mark_id", "name", "group_name"]]


COMPONENT_PARTS = {
    "Engine Oil": "engine_oil",
    "Oil Filter": "oil_filter",
    "Air Filter": "air_filter",
    "Cabin Air Filter": "cabin_filter",
    "Brake Fluid": "brake_fluid",
    "Brake Pads": "brake_pads",
    "Transmission Fluid": "transmission_oil",
    "Coolant": "coolant",
    "Spark Plugs": "spark_plugs",
    "Battery": "battery",
    "Tire Rotation": "tires",
    "Suspension": "suspension",
}


def _ratio_to_score(ratio: float) -> float:
    if ratio >= 1.2:
        return 1.0
    if ratio <= 0.6:
        return 0.0
    return (ratio - 0.6) / 0.6


def _need_score(
    mileage: int,
    target_mileage: int,
    *,
    engine_type: str | None = None,
    displacement: int | None = None,
    transmission: str | None = None,
    weight: int | None = None,
    part: str | None = None,
    coefficients: dict[str, float] | None = None,
) -> float:
    return coefficient_need_score(
        mileage,
        target_mileage,
        engine_type=engine_type,
        displacement=displacement,
        transmission=transmission,
        weight=weight,
        part=part,
        coefficients=coefficients or load_coefficients(),
    )


def predict(spec: CarSpec, usage: Usage) -> Dict[str, Any]:
    days_since = (datetime.now() - usage.last_maintenance_date).days
    needs: Dict[str, MaintenanceNeed] = {}
    urgent: List[str] = []

    for component, (km_interval, month_interval) in COMPONENT_INTERVALS.items():
        days_interval = month_interval * 30
        needed = usage.total_distance_km >= km_interval or days_since >= days_interval

        if needed:
            km_remaining = days_remaining = None
            reason = f"Distance: {usage.total_distance_km:.0f} km or Time: {days_since} days exceeded"
            urgent.append(component)
        else:
            km_remaining = int(km_interval - usage.total_distance_km)
            days_remaining = int(days_interval - days_since)
            reason = f"{km_remaining} km or {days_remaining} days remaining"

        needs[component] = MaintenanceNeed(component, needed, reason, km_remaining, days_remaining)

    return {
        "components": needs,
        "urgent_count": len(urgent),
        "urgent_services": urgent,
        "total_components": len(COMPONENT_INTERVALS),
        "analysis_date": datetime.now().isoformat(),
    }


def predict_maintenance(spec: CarSpec, usage: Usage) -> List[Dict[str, Any]]:
    days_since = (datetime.now() - usage.last_maintenance_date).days
    displacement = normalize_displacement_cc(spec.displacement)
    coefficients = load_coefficients()
    spec_kwargs = {
        "engine_type": spec.engine_type,
        "displacement": displacement,
        "transmission": spec.transmission,
        "weight": int(spec.weight),
        "coefficients": coefficients,
    }

    return [
        {
            "component": component,
            "maintenance need": round(
                max(
                    _need_score(
                        int(usage.total_distance_km),
                        km_interval,
                        part=COMPONENT_PARTS[component],
                        **spec_kwargs,
                    ),
                    _ratio_to_score(days_since / max(month_interval * 30, 1)),
                ),
                2,
            ),
        }
        for component, (km_interval, month_interval) in COMPONENT_INTERVALS.items()
    ]
