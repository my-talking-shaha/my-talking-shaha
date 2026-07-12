"""Vehicle spec normalization helpers."""

from __future__ import annotations


def normalize_displacement_cc(displacement: float | None) -> int | None:
    if displacement is None:
        return None
    value = float(displacement)
    if value <= 0:
        return None
    if value < 100:
        return int(round(value * 1000))
    return int(round(value))
