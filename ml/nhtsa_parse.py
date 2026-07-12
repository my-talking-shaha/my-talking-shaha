"""Parse NHTSA FLAT_CMPL complaint records."""

from __future__ import annotations

import zipfile
from pathlib import Path
from typing import Iterator

import pandas as pd

from ml.nhtsa_download import CMPL_TXT_NAME, DATA_DIR

CMPL_COLUMNS = [
    "cmplid",
    "odino",
    "manufacturer",
    "make",
    "model",
    "year",
    "crash",
    "faildate",
    "fire",
    "injured",
    "deaths",
    "compdesc",
    "city",
    "state",
    "vin",
    "date_added",
    "date_received",
    "miles",
    "occurrences",
    "description",
    "complaint_type",
    "police_report",
    "purchase_date",
    "original_owner",
    "anti_brakes",
    "cruise_control",
    "num_cyls",
    "drive_train",
    "fuel_sys",
    "fuel_type",
    "turbo",
    "supercharger",
    "other_fuel",
    "battery_type",
    "battery_info",
    "trailer_type",
    "trailer_mfr",
    "dealer_name",
    "dealer_city",
    "dealer_state",
    "dealer_zip",
    "dealer_phone",
    "manufacturer_date",
    "manufacturer_status",
    "manufacturer_dispute",
    "manufacturer_resolution",
    "manufacturer_reimburse",
    "medical_attention",
    "vehicle_towed",
    "state_of_incident",
    "vehicle_operator",
]

MILES_MIN = 1_000
MILES_MAX = 400_000
MI_TO_KM = 1.60934


def _resolve_cmpl_source(path: Path) -> tuple[Path, bool]:
    if path.suffix == ".zip":
        return path, True
    if path.exists():
        return path, False
    zip_path = path.with_suffix(".zip")
    if zip_path.exists():
        return zip_path, True
    raise FileNotFoundError(f"NHTSA complaint file not found: {path}")


def iter_cmpl_chunks(
    source_path: Path | None = None,
    *,
    chunksize: int = 50_000,
) -> Iterator[pd.DataFrame]:
    source_path = source_path or DATA_DIR / CMPL_TXT_NAME
    resolved, is_zip = _resolve_cmpl_source(source_path)

    if is_zip:
        with zipfile.ZipFile(resolved) as archive:
            with archive.open(CMPL_TXT_NAME) as handle:
                reader = pd.read_csv(
                    handle,
                    sep="\t",
                    header=None,
                    names=CMPL_COLUMNS,
                    dtype=str,
                    chunksize=chunksize,
                    on_bad_lines="skip",
                    encoding="latin-1",
                )
                yield from reader
        return

    reader = pd.read_csv(
        resolved,
        sep="\t",
        header=None,
        names=CMPL_COLUMNS,
        dtype=str,
        chunksize=chunksize,
        on_bad_lines="skip",
        encoding="latin-1",
    )
    yield from reader


def normalize_complaints(df: pd.DataFrame) -> pd.DataFrame:
    frame = df.copy()
    frame["make"] = frame["make"].fillna("").str.strip().str.upper()
    frame["model"] = frame["model"].fillna("").str.strip().str.upper()
    frame["year"] = pd.to_numeric(frame["year"], errors="coerce")
    frame["miles"] = pd.to_numeric(frame["miles"], errors="coerce")
    frame["num_cyls"] = pd.to_numeric(frame["num_cyls"], errors="coerce")
    frame["compdesc"] = frame["compdesc"].fillna("").str.strip().str.upper()
    frame["description"] = frame["description"].fillna("").str.strip().str.upper()
    frame["fuel_type"] = frame["fuel_type"].fillna("").str.strip().str.upper()
    frame["drive_train"] = frame["drive_train"].fillna("").str.strip().str.upper()
    frame["fuel_sys"] = frame["fuel_sys"].fillna("").str.strip().str.upper()
    frame["vin"] = frame["vin"].fillna("").str.strip()

    frame = frame[
        frame["miles"].between(MILES_MIN, MILES_MAX)
        & frame["make"].ne("")
        & frame["model"].ne("")
        & frame["year"].notna()
        & frame["compdesc"].ne("")
    ].copy()

    frame["failure_km"] = (frame["miles"] * MI_TO_KM).round().astype(int)
    frame["decade"] = (frame["year"] // 10 * 10).astype(int)
    return frame


def load_complaints(
    source_path: Path | None = None,
    *,
    max_rows: int | None = None,
    chunksize: int = 50_000,
) -> pd.DataFrame:
    frames: list[pd.DataFrame] = []
    total = 0

    for chunk in iter_cmpl_chunks(source_path, chunksize=chunksize):
        normalized = normalize_complaints(chunk)
        if normalized.empty:
            continue
        frames.append(normalized)
        total += len(normalized)
        if max_rows is not None and total >= max_rows:
            break

    if not frames:
        return pd.DataFrame(columns=CMPL_COLUMNS + ["failure_km", "decade"])

    result = pd.concat(frames, ignore_index=True)
    if max_rows is not None:
        result = result.head(max_rows)
    return result
