"""Download NHTSA complaint bulk data and optional recall metadata."""

from __future__ import annotations

import argparse
import json
import zipfile
from pathlib import Path
from typing import Iterable

import httpx

DATA_DIR = Path(__file__).parent / "data" / "nhtsa"
CMPL_ZIP_URL = "https://static.nhtsa.gov/odi/ffdd/cmpl/FLAT_CMPL.zip"
CMPL_TXT_NAME = "FLAT_CMPL.txt"
SCHEMA_URL = "https://static.nhtsa.gov/odi/ffdd/cmpl/CMPL.txt"
RECALLS_API = "https://api.nhtsa.gov/recalls/recallsByVehicle"


def download_file(url: str, destination: Path, *, chunk_size: int = 1 << 20) -> Path:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with httpx.stream("GET", url, follow_redirects=True, timeout=600.0) as response:
        response.raise_for_status()
        with destination.open("wb") as handle:
            for chunk in response.iter_bytes(chunk_size):
                handle.write(chunk)
    return destination


def extract_cmpl_txt(zip_path: Path, destination: Path) -> Path:
    with zipfile.ZipFile(zip_path) as archive:
        with archive.open(CMPL_TXT_NAME) as source, destination.open("wb") as target:
            while True:
                chunk = source.read(1 << 20)
                if not chunk:
                    break
                target.write(chunk)
    return destination


def download_cmpl(data_dir: Path | None = None, *, extract: bool = True) -> Path:
    data_dir = data_dir or DATA_DIR
    data_dir.mkdir(parents=True, exist_ok=True)

    schema_path = data_dir / "CMPL_schema.txt"
    if not schema_path.exists():
        download_file(SCHEMA_URL, schema_path)

    zip_path = data_dir / "FLAT_CMPL.zip"
    if not zip_path.exists():
        print(f"Downloading {CMPL_ZIP_URL} ...")
        download_file(CMPL_ZIP_URL, zip_path)

    txt_path = data_dir / CMPL_TXT_NAME
    if extract and not txt_path.exists():
        print(f"Extracting {CMPL_TXT_NAME} ...")
        extract_cmpl_txt(zip_path, txt_path)

    return txt_path if extract and txt_path.exists() else zip_path


def fetch_recalls_for_vehicle(make: str, model: str, model_year: int) -> list[dict]:
    params = {"make": make, "model": model, "modelYear": model_year}
    response = httpx.get(RECALLS_API, params=params, timeout=30.0)
    response.raise_for_status()
    payload = response.json()
    return payload.get("results", [])


def save_recall_index(records: Iterable[dict], destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("w", encoding="utf-8") as handle:
        json.dump(list(records), handle, ensure_ascii=False, indent=2)


def main() -> None:
    parser = argparse.ArgumentParser(description="Download NHTSA complaint bulk data.")
    parser.add_argument("--data-dir", type=Path, default=DATA_DIR)
    parser.add_argument("--no-extract", action="store_true", help="Keep only the ZIP archive.")
    args = parser.parse_args()

    path = download_cmpl(args.data_dir, extract=not args.no_extract)
    print(f"NHTSA data ready at {path}")


if __name__ == "__main__":
    main()
