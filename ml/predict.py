"""Maintenance prediction: models, CSV loader, predict()."""

from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

import pandas as pd

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


@dataclass
class CarSpec:
    engine_type: str
    displacement: Optional[float]
    transmission: str
    weight: float


@dataclass
class Usage:
    total_distance_km: float
    average_speed: float
    altitude_gain: float
    total_trips: int
    median_trip_duration: float
    last_maintenance_date: datetime


@dataclass
class MaintenanceNeed:
    name: str
    needed: bool
    reason: str
    km_remaining: Optional[int]
    days_remaining: Optional[int]


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


def _need_score(mileage: int, target_mileage: int, *, engine_type: str | None = None, displacement: int | None = None, transmission: str | None = None, weight: int | None = None, part: str | None = None) -> float:
    effective_target = float(target_mileage)
    if engine_type == "Дизельный":
        if part in {"fuel_filter", "injectors"}:
            # У дизелей топливная система чувствительнее
            effective_target *= 0.8
    elif engine_type == "Гибридный":
        if part in {"brake_pads", "brake_discs"}:
            # Рекуперация снижает износ тормозов
            effective_target *= 1.5
        if part in {"engine_oil", "oil_filter"}:
            # ДВС работает меньше времени
            effective_target *= 1.15
    elif engine_type == "Электро":
        if part in {
            "engine_oil",
            "oil_filter",
            "spark_plugs",
            "fuel_filter",
            "injectors",
            "timing_belt",
        }:
            return 0.0
        if part in {"brake_pads", "brake_discs"}:
            effective_target *= 1.6
        if part in {"tires", "suspension"}:
            # EV обычно тяжелее
            effective_target *= 0.9
    elif engine_type == "Бензиновый":
        if part == "spark_plugs":
            # Малолитражные турбированные моторы обычно требуют
            # более частой замены свечей
            if displacement is not None and displacement <= 1600:
                effective_target *= 0.8
            elif displacement >= 3000:
                effective_target *= 1.1
    if transmission == "Автомат":
        if part in {"transmission_oil", "transmission_filter"}:
            effective_target *= 0.85

    elif transmission == "Механика":
        if part in {"clutch"}:
            effective_target *= 0.9

        if part in {"transmission_oil", "transmission_filter"}:
            effective_target *= 1.15
    if weight is not None:
        if weight > 2200:
            if part in {
                "brake_pads",
                "brake_discs",
                "tires",
                "suspension",
                "wheel_bearing",
            }:
                effective_target *= 0.85

        elif weight < 1300:
            if part in {
                "brake_pads",
                "brake_discs",
                "tires",
                "suspension",
            }:
                effective_target *= 1.1
    ratio = mileage / max(effective_target, 1)

    if ratio >= 1.2:
        return 1.0
    if ratio <= 0.6:
        return 0.0

    return (ratio - 0.6) / 0.6


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
    displacement = int(spec.displacement) if spec.displacement is not None else None
    spec_kwargs = {
        "engine_type": spec.engine_type,
        "displacement": displacement,
        "transmission": spec.transmission,
        "weight": int(spec.weight),
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