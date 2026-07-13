"""Map NHTSA complaint components to predictor part keys."""

from __future__ import annotations

import re
from dataclasses import dataclass

PART_KEYS = {
    "engine_oil",
    "oil_filter",
    "air_filter",
    "cabin_filter",
    "brake_fluid",
    "brake_pads",
    "transmission_oil",
    "coolant",
    "spark_plugs",
    "battery",
    "tires",
    "suspension",
}

PART_TO_COMPONENT = {
    "engine_oil": "Engine Oil",
    "oil_filter": "Oil Filter",
    "air_filter": "Air Filter",
    "cabin_filter": "Cabin Air Filter",
    "brake_fluid": "Brake Fluid",
    "brake_pads": "Brake Pads",
    "transmission_oil": "Transmission Fluid",
    "coolant": "Coolant",
    "spark_plugs": "Spark Plugs",
    "battery": "Battery",
    "tires": "Tire Rotation",
    "suspension": "Suspension",
}


@dataclass(frozen=True)
class ComponentRule:
    part: str
    patterns: tuple[str, ...]
    exclude: tuple[str, ...] = ()


RULES: tuple[ComponentRule, ...] = (
    ComponentRule("engine_oil", ("ENGINE OIL", "LUBRICATION", "OIL LEAK", "OIL CONSUMPTION")),
    ComponentRule("oil_filter", ("OIL FILTER",), exclude=("AIR FILTER", "CABIN")),
    ComponentRule("air_filter", ("AIR FILTER", "INTAKE MANIFOLD", "INTAKE/AIR")),
    ComponentRule("cabin_filter", ("CABIN AIR", "HVAC", "HEATER", "A/C", "AIR CONDITION")),
    ComponentRule("brake_fluid", ("BRAKE FLUID", "HYDRAULIC:FLUID", "MASTER CYLINDER")),
    ComponentRule(
        "brake_pads",
        ("BRAKE PAD", "BRAKE DISC", "FOUNDATION COMPONENTS", "SERVICE BRAKES", "ABS", "ANTILOCK"),
        exclude=("BRAKE FLUID", "PARKING BRAKE"),
    ),
    ComponentRule(
        "transmission_oil",
        (
            "TRANSMISSION FLUID",
            "AUTOMATIC TRANSMISSION",
            "MANUAL TRANSMISSION",
            "POWER TRAIN",
            "CLUTCH",
            "DRIVELINE",
        ),
        exclude=("ENGINE", "COOLING SYSTEM"),
    ),
    ComponentRule("coolant", ("COOLING SYSTEM", "COOLANT", "RADIATOR", "WATER PUMP", "THERMOSTAT")),
    ComponentRule("spark_plugs", ("SPARK PLUG", "IGNITION", "COIL")),
    ComponentRule("battery", ("BATTERY", "STARTER", "ALTERNATOR", "ELECTRICAL SYSTEM:12V")),
    ComponentRule("tires", ("TIRE", "TREAD", "WHEEL")),
    ComponentRule(
        "suspension",
        ("SUSPENSION", "SHOCK", "STRUT", "CONTROL ARM", "STEERING:LINKAGE", "STEERING:RACK"),
    ),
)


def map_compdesc(compdesc: str, description: str = "") -> str | None:
    text = f"{compdesc} {description}".upper()
    for rule in RULES:
        if any(exclude in text for exclude in rule.exclude):
            continue
        if any(re.search(pattern, text) for pattern in rule.patterns):
            return rule.part
    return None


def map_recall_component(component: str) -> str | None:
    return map_compdesc(component.upper())


def recall_key(make: str, model: str, year: int, component: str) -> tuple[str, str, int, str]:
    return (make.upper(), model.upper(), int(year), component.upper())
