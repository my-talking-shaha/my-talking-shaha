"""Learnable maintenance interval coefficients."""

from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Any

import torch
import torch.nn as nn

COEFFICIENTS_PATH = Path(__file__).parent / "coefficients.json"

ICE_PARTS = {
    "engine_oil",
    "oil_filter",
    "spark_plugs",
    "fuel_filter",
    "injectors",
    "timing_belt",
}

PART_KEYS = [
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
]

DEFAULT_COEFFICIENTS: dict[str, float] = {
    "diesel.fuel_filter": 0.8,
    "diesel.injectors": 0.8,
    "hybrid.brake_pads": 1.5,
    "hybrid.brake_discs": 1.5,
    "hybrid.engine_oil": 1.15,
    "hybrid.oil_filter": 1.15,
    "electric.brake_pads": 1.6,
    "electric.brake_discs": 1.6,
    "electric.tires": 0.9,
    "electric.suspension": 0.9,
    "gasoline.spark_plugs.small": 0.8,
    "gasoline.spark_plugs.large": 1.1,
    "automatic.transmission_oil": 0.85,
    "automatic.transmission_filter": 0.85,
    "manual.clutch": 0.9,
    "manual.transmission_oil": 1.15,
    "manual.transmission_filter": 1.15,
    "weight.heavy.brake_pads": 0.85,
    "weight.heavy.brake_discs": 0.85,
    "weight.heavy.tires": 0.85,
    "weight.heavy.suspension": 0.85,
    "weight.heavy.wheel_bearing": 0.85,
    "weight.light.brake_pads": 1.1,
    "weight.light.brake_discs": 1.1,
    "weight.light.tires": 1.1,
    "weight.light.suspension": 1.1,
}
DEFAULT_COEFFICIENTS.update({f"part_scale.{part}": 1.0 for part in PART_KEYS})

ENGINE_ALIASES = {
    "Бензиновый": "gasoline",
    "Дизельный": "diesel",
    "Гибридный": "hybrid",
    "Электро": "electric",
    "petrol": "gasoline",
}

TRANSMISSION_ALIASES = {
    "Автомат": "automatic",
    "Механика": "manual",
    "automatic": "automatic",
    "manual": "manual",
}


def load_coefficients(path: Path | None = None) -> dict[str, float]:
    path = path or COEFFICIENTS_PATH
    if not path.exists():
        return dict(DEFAULT_COEFFICIENTS)
    payload = json.loads(path.read_text(encoding="utf-8"))
    merged = dict(DEFAULT_COEFFICIENTS)
    merged.update(payload.get("coefficients", payload))
    return merged


def save_coefficients(
    coefficients: dict[str, float],
    path: Path | None = None,
    metadata: dict[str, Any] | None = None,
) -> None:
    path = path or COEFFICIENTS_PATH
    payload = {"coefficients": coefficients}
    if metadata:
        payload["metadata"] = metadata
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")


def _engine_key(engine_type: str | None) -> str | None:
    if not engine_type:
        return None
    return ENGINE_ALIASES.get(engine_type, ENGINE_ALIASES.get(engine_type.capitalize()))


def _transmission_key(transmission: str | None) -> str | None:
    if not transmission:
        return None
    return TRANSMISSION_ALIASES.get(transmission, TRANSMISSION_ALIASES.get(transmission.capitalize()))


def apply_coefficients(
    target_mileage: float,
    *,
    engine_type: str | None = None,
    displacement: int | None = None,
    transmission: str | None = None,
    weight: int | None = None,
    part: str | None = None,
    coefficients: dict[str, float] | None = None,
) -> float:
    coeffs = coefficients or load_coefficients()
    effective = float(target_mileage)
    engine = _engine_key(engine_type)
    trans = _transmission_key(transmission)
    part_key = part or ""
    if part_key:
        effective *= coeffs.get(f"part_scale.{part_key}", 1.0)

    if engine == "diesel" and part_key in {"fuel_filter", "injectors"}:
        effective *= coeffs.get(f"diesel.{part_key}", 1.0)
    elif engine == "hybrid":
        if part_key in {"brake_pads", "brake_discs"}:
            effective *= coeffs.get(f"hybrid.{part_key}", 1.0)
        if part_key in {"engine_oil", "oil_filter"}:
            effective *= coeffs.get(f"hybrid.{part_key}", 1.0)
    elif engine == "electric":
        if part_key in ICE_PARTS:
            return 0.0
        if part_key in {"brake_pads", "brake_discs"}:
            effective *= coeffs.get(f"electric.{part_key}", 1.0)
        if part_key in {"tires", "suspension"}:
            effective *= coeffs.get(f"electric.{part_key}", 1.0)
    elif engine == "gasoline" and part_key == "spark_plugs":
        if displacement is not None and displacement <= 1600:
            effective *= coeffs.get("gasoline.spark_plugs.small", 1.0)
        elif displacement is not None and displacement >= 3000:
            effective *= coeffs.get("gasoline.spark_plugs.large", 1.0)

    if trans == "automatic" and part_key in {"transmission_oil", "transmission_filter"}:
        effective *= coeffs.get(f"automatic.{part_key}", 1.0)
    elif trans == "manual":
        if part_key == "clutch":
            effective *= coeffs.get("manual.clutch", 1.0)
        if part_key in {"transmission_oil", "transmission_filter"}:
            effective *= coeffs.get(f"manual.{part_key}", 1.0)

    if weight is not None:
        if weight > 2200 and part_key in {"brake_pads", "brake_discs", "tires", "suspension", "wheel_bearing"}:
            effective *= coeffs.get(f"weight.heavy.{part_key}", 1.0)
        elif weight < 1300 and part_key in {"brake_pads", "brake_discs", "tires", "suspension"}:
            effective *= coeffs.get(f"weight.light.{part_key}", 1.0)

    return max(effective, 1.0)


def ratio_to_score(ratio: float) -> float:
    if ratio >= 1.2:
        return 1.0
    if ratio <= 0.6:
        return 0.0
    return (ratio - 0.6) / 0.6


def need_score(
    mileage: float,
    target_mileage: float,
    *,
    engine_type: str | None = None,
    displacement: int | None = None,
    transmission: str | None = None,
    weight: int | None = None,
    part: str | None = None,
    coefficients: dict[str, float] | None = None,
) -> float:
    effective = apply_coefficients(
        target_mileage,
        engine_type=engine_type,
        displacement=displacement,
        transmission=transmission,
        weight=weight,
        part=part,
        coefficients=coefficients,
    )
    if effective == 0.0:
        return 0.0
    return ratio_to_score(float(mileage) / effective)


def ratio_to_score_tensor(ratio: torch.Tensor) -> torch.Tensor:
    score = ((ratio - 0.6) / 0.6).clamp(0.0, 1.0)
    score = torch.where(ratio >= 1.2, torch.ones_like(score), score)
    score = torch.where(ratio <= 0.6, torch.zeros_like(score), score)
    return score


class CoefficientModel(nn.Module):
    def __init__(self, initial: dict[str, float] | None = None) -> None:
        super().__init__()
        initial = initial or DEFAULT_COEFFICIENTS
        self.keys = list(initial.keys())
        logs = [math.log(max(value, 1e-6)) for value in initial.values()]
        self.log_coeffs = nn.Parameter(torch.tensor(logs, dtype=torch.float32))
        self.register_buffer("init_logs", torch.tensor(logs, dtype=torch.float32), persistent=False)

    def get(self, key: str) -> torch.Tensor:
        index = self.keys.index(key)
        return torch.exp(self.log_coeffs[index])

    def coefficients_dict(self) -> dict[str, float]:
        values = torch.exp(self.log_coeffs).detach().cpu().tolist()
        return dict(zip(self.keys, values))

    def effective_interval(
        self,
        base_interval: torch.Tensor,
        engine: list[str | None],
        transmission: list[str | None],
        displacement: list[int | None],
        weight: list[int | None],
        parts: list[str | None],
    ) -> torch.Tensor:
        sample_mults: list[torch.Tensor] = []
        for idx in range(len(parts)):
            part = parts[idx] or ""
            engine_key = _engine_key(engine[idx])
            trans_key = _transmission_key(transmission[idx])
            disp = displacement[idx]
            wt = weight[idx]
            sample_mult = torch.tensor(1.0, dtype=base_interval.dtype)
            if part:
                sample_mult = sample_mult * self.get(f"part_scale.{part}")

            if engine_key == "diesel" and part in {"fuel_filter", "injectors"}:
                sample_mult = sample_mult * self.get(f"diesel.{part}")
            elif engine_key == "hybrid":
                if part in {"brake_pads", "brake_discs", "engine_oil", "oil_filter"}:
                    sample_mult = sample_mult * self.get(f"hybrid.{part}")
            elif engine_key == "electric":
                if part in ICE_PARTS:
                    sample_mults.append(torch.tensor(0.0, dtype=base_interval.dtype))
                    continue
                if part in {"brake_pads", "brake_discs", "tires", "suspension"}:
                    sample_mult = sample_mult * self.get(f"electric.{part}")
            elif engine_key == "gasoline" and part == "spark_plugs":
                if disp is not None and disp <= 1600:
                    sample_mult = sample_mult * self.get("gasoline.spark_plugs.small")
                elif disp is not None and disp >= 3000:
                    sample_mult = sample_mult * self.get("gasoline.spark_plugs.large")

            if trans_key == "automatic" and part in {"transmission_oil", "transmission_filter"}:
                sample_mult = sample_mult * self.get(f"automatic.{part}")
            elif trans_key == "manual":
                if part == "clutch":
                    sample_mult = sample_mult * self.get("manual.clutch")
                if part in {"transmission_oil", "transmission_filter"}:
                    sample_mult = sample_mult * self.get(f"manual.{part}")

            if wt is not None:
                if wt > 2200 and part in {"brake_pads", "brake_discs", "tires", "suspension", "wheel_bearing"}:
                    sample_mult = sample_mult * self.get(f"weight.heavy.{part}")
                elif wt < 1300 and part in {"brake_pads", "brake_discs", "tires", "suspension"}:
                    sample_mult = sample_mult * self.get(f"weight.light.{part}")

            sample_mults.append(sample_mult)

        multipliers = torch.stack(sample_mults)
        return (base_interval * multipliers).clamp_min(1.0)

    def forward(
        self,
        mileage: torch.Tensor,
        base_interval: torch.Tensor,
        engine: list[str | None],
        transmission: list[str | None],
        displacement: list[int | None],
        weight: list[int | None],
        parts: list[str | None],
    ) -> torch.Tensor:
        effective = self.effective_interval(base_interval, engine, transmission, displacement, weight, parts)
        ratio = mileage / effective
        scores = ratio_to_score_tensor(ratio)
        zero_mask = torch.tensor(
            [
                _engine_key(engine[idx]) == "electric" and (parts[idx] or "") in ICE_PARTS
                for idx in range(len(parts))
            ],
            dtype=torch.bool,
        )
        return torch.where(zero_mask, torch.zeros_like(scores), scores)

    def regularization(self, lam: float = 0.01) -> torch.Tensor:
        return lam * torch.sum((self.log_coeffs - self.init_logs) ** 2)
