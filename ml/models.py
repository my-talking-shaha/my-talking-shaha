"""
Data models for maintenance prediction.
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


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
