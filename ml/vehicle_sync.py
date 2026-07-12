"""Map NHTSA vehicle fields to CarSpec used by the predictor."""

from __future__ import annotations

import json
import re
import time
from pathlib import Path
from typing import Any

import httpx
import pandas as pd

from ml.models import CarSpec

DATA_DIR = Path(__file__).parent / "data"
VPIC_CACHE_PATH = DATA_DIR / "vpic_cache.json"
VPIC_BASE = "https://vpic.nhtsa.dot.gov/api/vehicles"

FUEL_TYPE_MAP = {
    "GS": "Бензиновый",
    "GAS": "Бензиновый",
    "BF": "Бензиновый",
    "DS": "Дизельный",
    "HE": "Гибридный",
    "EL": "Электро",
    "ELE": "Электро",
    "EV": "Электро",
    "CN": "Бензиновый",
}

DEFAULT_WEIGHT_KG = 1600.0


class VpicCache:
    def __init__(self, cache_path: Path | None = None) -> None:
        self.cache_path = cache_path or VPIC_CACHE_PATH
        self.cache_path.parent.mkdir(parents=True, exist_ok=True)
        self._data: dict[str, dict[str, Any]] = {}
        if self.cache_path.exists():
            self._data = json.loads(self.cache_path.read_text(encoding="utf-8"))

    def get(self, key: str) -> dict[str, Any] | None:
        return self._data.get(key)

    def set(self, key: str, value: dict[str, Any]) -> None:
        self._data[key] = value
        self.cache_path.write_text(json.dumps(self._data, ensure_ascii=False, indent=2), encoding="utf-8")


def map_fuel_type(fuel_type: str | None) -> str:
    code = (fuel_type or "").strip().upper()
    return FUEL_TYPE_MAP.get(code, "Бензиновый")


def map_transmission(
    drive_train: str | None,
    compdesc: str = "",
    description: str = "",
    vpic_transmission: str | None = None,
) -> str:
    text = f"{compdesc} {description} {vpic_transmission or ''}".upper()
    if vpic_transmission:
        style = vpic_transmission.upper()
        if any(token in style for token in ("AUTOMATIC", "CVT", "AMT", "DCT", "AUTO")):
            return "Автомат"
        if "MANUAL" in style:
            return "Механика"

    if "MANUAL TRANSMISSION" in text or re.search(r"\bMT\b", text):
        return "Механика"
    if any(token in text for token in ("AUTOMATIC TRANSMISSION", "CVT", "DCT", " AUTO ")):
        return "Автомат"

    drive = (drive_train or "").strip().upper()
    if drive in {"AWD", "4WD", "FWD", "RWD"}:
        return "Автомат"
    return "unknown"


def estimate_displacement_cc(num_cyls: float | None) -> int | None:
    if num_cyls is None or pd.isna(num_cyls) or num_cyls <= 0:
        return None
    return int(round(float(num_cyls) * 500))


def _parse_vpic_value(raw: str | None) -> float | None:
    if not raw:
        return None
    match = re.search(r"[\d.]+", raw.replace(",", ""))
    if not match:
        return None
    return float(match.group())


def fetch_vpic_specs(make: str, model: str, year: int, cache: VpicCache | None = None) -> dict[str, Any]:
    cache = cache or VpicCache()
    key = f"{make.upper()}|{model.upper()}|{year}"
    cached = cache.get(key)
    if cached is not None:
        return cached

    url = f"{VPIC_BASE}/GetModelsForMakeYear/make/{make}/modelyear/{year}?format=json"
    specs: dict[str, Any] = {}
    try:
        response = httpx.get(url, timeout=20.0)
        response.raise_for_status()
        models = response.json().get("Results", [])
        model_upper = model.upper()
        match = next((item for item in models if model_upper in item.get("Model_Name", "").upper()), None)
        if match is not None:
            model_id = match.get("Model_ID")
            detail_url = f"{VPIC_BASE}/GetModelDetails/{model_id}?format=json"
            detail = httpx.get(detail_url, timeout=20.0)
            detail.raise_for_status()
            for item in detail.json().get("Results", []):
                name = item.get("Name")
                value = item.get("Value")
                if name == "Displacement (L)":
                    liters = _parse_vpic_value(value)
                    if liters is not None:
                        specs["displacement_cc"] = int(round(liters * 1000))
                elif name in {"Curb Weight (lbs)", "Gross Vehicle Weight Rating From"}:
                    pounds = _parse_vpic_value(value)
                    if pounds is not None and "weight_kg" not in specs:
                        specs["weight_kg"] = round(pounds * 0.453592, 1)
                elif name == "Transmission Style":
                    specs["transmission_style"] = value
        time.sleep(0.05)
    except httpx.HTTPError:
        specs = {}

    cache.set(key, specs)
    return specs


def row_to_car_spec(
    row: pd.Series | dict[str, Any],
    *,
    cache: VpicCache | None = None,
    use_vpic: bool = True,
) -> CarSpec:
    if isinstance(row, pd.Series):
        data = row.to_dict()
    else:
        data = row

    make = str(data.get("make", "")).strip()
    model = str(data.get("model", "")).strip()
    year = int(float(data.get("year", 0) or 0))
    compdesc = str(data.get("compdesc", ""))
    description = str(data.get("description", ""))

    vpic_specs: dict[str, Any] = {}
    if use_vpic and make and model and year:
        vpic_specs = fetch_vpic_specs(make, model, year, cache)

    displacement = vpic_specs.get("displacement_cc")
    if displacement is None:
        displacement = estimate_displacement_cc(pd.to_numeric(data.get("num_cyls"), errors="coerce"))

    weight = vpic_specs.get("weight_kg", DEFAULT_WEIGHT_KG)
    transmission = map_transmission(
        str(data.get("drive_train", "")),
        compdesc=compdesc,
        description=description,
        vpic_transmission=vpic_specs.get("transmission_style"),
    )
    engine_type = map_fuel_type(str(data.get("fuel_type", "")))

    return CarSpec(
        engine_type=engine_type,
        displacement=float(displacement) if displacement is not None else None,
        transmission=transmission,
        weight=float(weight),
    )
