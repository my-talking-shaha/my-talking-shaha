"""Train maintenance coefficients on NHTSA complaint data."""

from __future__ import annotations

import argparse
import json
import random
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path

import pandas as pd
import torch
from torch.utils.data import DataLoader, Dataset
from tqdm import tqdm

from ml.coefficients import CoefficientModel, DEFAULT_COEFFICIENTS, save_coefficients
from ml.component_mapping import PART_TO_COMPONENT, map_compdesc
from ml.nhtsa_download import DATA_DIR, download_cmpl
from ml.nhtsa_parse import iter_cmpl_chunks, normalize_complaints
from ml.predict import COMPONENT_INTERVALS
from ml.spec_utils import normalize_displacement_cc
from ml.vehicle_sync import VpicCache, row_to_car_spec

REPORT_PATH = Path(__file__).parent / "data" / "training_report.json"
ALERT_THRESHOLD = 0.83
SAFE_THRESHOLD = 0.40
ALERT_OFFSET_KM = 50
SAFE_RATIO = 0.55
OVERDUE_OFFSET_KM = 100
INTERVAL_TARGET_RATIO = 1.098
MAX_PER_GROUP = 20
MIN_PER_MAKE = 30
TOP_MAKES = 60
MI_TO_KM = 1.60934


@dataclass
class TrainingPoint:
    mileage_km: float
    base_interval_km: float
    interval_target_km: float
    engine_type: str
    transmission: str
    displacement_cc: int | None
    weight_kg: int
    part: str
    target_type: str
    sample_weight: float
    make: str
    model: str


class TrainingDataset(Dataset):
    def __init__(self, points: list[TrainingPoint]) -> None:
        self.points = points

    def __len__(self) -> int:
        return len(self.points)

    def __getitem__(self, index: int) -> TrainingPoint:
        return self.points[index]


def _base_interval_for_part(part: str) -> float:
    component = PART_TO_COMPONENT[part]
    return float(COMPONENT_INTERVALS[component][0])


def stratified_sample_complaints(
    source_path: Path,
    *,
    max_complaints: int = 20_000,
    seed: int = 42,
    use_vpic: bool = False,
) -> pd.DataFrame:
    rng = random.Random(seed)
    group_counts: Counter[tuple[str, ...]] = Counter()
    make_counts: Counter[str] = Counter()
    selected_rows: list[dict] = []

    for chunk in iter_cmpl_chunks(source_path):
        normalized = normalize_complaints(chunk)
        if normalized.empty:
            continue

        for _, row in normalized.iterrows():
            part = map_compdesc(row["compdesc"], row["description"])
            if part is None or row["failure_km"] < 500:
                continue

            group = (row["make"], row["model"], str(row["decade"]), part)
            if group_counts[group] >= MAX_PER_GROUP:
                continue

            selected_rows.append(row.to_dict())
            group_counts[group] += 1
            make_counts[row["make"]] += 1

            if len(selected_rows) >= max_complaints:
                break
        if len(selected_rows) >= max_complaints:
            break

    frame = pd.DataFrame(selected_rows)
    if frame.empty:
        return frame

    top_makes = {make for make, _ in make_counts.most_common(TOP_MAKES)}
    frame = frame[frame["make"].isin(top_makes)].copy()

    for make in top_makes:
        if make_counts[make] < MIN_PER_MAKE:
            continue

    return frame.sample(frac=1.0, random_state=seed).reset_index(drop=True)


def build_training_points(
    complaints: pd.DataFrame,
    *,
    use_vpic: bool = False,
) -> list[TrainingPoint]:
    cache = VpicCache()
    points: list[TrainingPoint] = []

    for _, row in complaints.iterrows():
        part = map_compdesc(row["compdesc"], row["description"])
        if part is None:
            continue

        spec = row_to_car_spec(row, cache=cache, use_vpic=use_vpic)
        displacement_cc = normalize_displacement_cc(spec.displacement)
        weight_kg = int(spec.weight)
        base_interval = _base_interval_for_part(part)
        failure_km = float(row["failure_km"])

        scenarios = [
            (failure_km - ALERT_OFFSET_KM, "alert", 1.0),
            (max(failure_km * SAFE_RATIO, 500.0), "safe", 1.0),
            (failure_km + OVERDUE_OFFSET_KM, "overdue", 0.8),
        ]
        for mileage_km, target_type, weight in scenarios:
            if mileage_km <= 0:
                continue
            points.append(
                TrainingPoint(
                    mileage_km=mileage_km,
                    base_interval_km=base_interval,
                    interval_target_km=failure_km / INTERVAL_TARGET_RATIO,
                    engine_type=spec.engine_type,
                    transmission=spec.transmission,
                    displacement_cc=displacement_cc,
                    weight_kg=weight_kg,
                    part=part,
                    target_type=target_type,
                    sample_weight=weight,
                    make=str(row["make"]),
                    model=str(row["model"]),
                )
            )
    return points


def split_points(points: list[TrainingPoint], *, val_ratio: float = 0.2, seed: int = 42) -> tuple[list[TrainingPoint], list[TrainingPoint]]:
    groups: dict[tuple[str, str], list[TrainingPoint]] = defaultdict(list)
    for point in points:
        groups[(point.make, point.model)].append(point)

    rng = random.Random(seed)
    group_keys = list(groups.keys())
    rng.shuffle(group_keys)
    split_index = int(len(group_keys) * (1 - val_ratio))
    train_groups = set(group_keys[:split_index])

    train = [point for key in train_groups for point in groups[key]]
    val = [point for key in group_keys[split_index:] for point in groups[key]]
    return train, val


def collate_batch(batch: list[TrainingPoint]) -> dict:
    return {
        "mileage": torch.tensor([item.mileage_km for item in batch], dtype=torch.float32),
        "base_interval": torch.tensor([item.base_interval_km for item in batch], dtype=torch.float32),
        "interval_target": torch.tensor([item.interval_target_km for item in batch], dtype=torch.float32),
        "engine": [item.engine_type for item in batch],
        "transmission": [item.transmission for item in batch],
        "displacement": [item.displacement_cc for item in batch],
        "weight": [item.weight_kg for item in batch],
        "parts": [item.part for item in batch],
        "target_type": [item.target_type for item in batch],
        "sample_weight": torch.tensor([item.sample_weight for item in batch], dtype=torch.float32),
    }


def compute_loss(model: CoefficientModel, batch: dict, *, reg_lambda: float = 0.01) -> torch.Tensor:
    scores = model(
        batch["mileage"],
        batch["base_interval"],
        batch["engine"],
        batch["transmission"],
        batch["displacement"],
        batch["weight"],
        batch["parts"],
    )
    loss = torch.zeros((), dtype=torch.float32)
    weights = batch["sample_weight"]

    for idx, target_type in enumerate(batch["target_type"]):
        score = scores[idx]
        if target_type == "alert":
            loss = loss + weights[idx] * torch.relu(torch.tensor(ALERT_THRESHOLD) - score)
        elif target_type == "safe":
            loss = loss + weights[idx] * torch.relu(score - torch.tensor(SAFE_THRESHOLD))
        elif target_type == "overdue":
            loss = loss + weights[idx] * (score - 1.0) ** 2

    interval_targets = batch.get("interval_target")
    if interval_targets is not None:
        predicted = model.effective_interval(
            batch["base_interval"],
            batch["engine"],
            batch["transmission"],
            batch["displacement"],
            batch["weight"],
            batch["parts"],
        )
        valid = interval_targets > 0
        if valid.any():
            loss = loss + torch.mean(
                (torch.log(predicted[valid]) - torch.log(interval_targets[valid])) ** 2
            )

    loss = loss / max(len(batch["target_type"]), 1)
    loss = loss + model.regularization(reg_lambda)
    return loss


def evaluate(model: CoefficientModel, points: list[TrainingPoint]) -> dict[str, float]:
    alert_total = alert_hits = 0
    safe_total = false_alarms = 0

    for point in points:
        if point.target_type == "alert":
            alert_total += 1
            score = model(
                torch.tensor([point.mileage_km]),
                torch.tensor([point.base_interval_km]),
                [point.engine_type],
                [point.transmission],
                [point.displacement_cc],
                [point.weight_kg],
                [point.part],
            ).item()
            if score >= ALERT_THRESHOLD:
                alert_hits += 1
        elif point.target_type == "safe":
            safe_total += 1
            score = model(
                torch.tensor([point.mileage_km]),
                torch.tensor([point.base_interval_km]),
                [point.engine_type],
                [point.transmission],
                [point.displacement_cc],
                [point.weight_kg],
                [point.part],
            ).item()
            if score >= ALERT_THRESHOLD:
                false_alarms += 1

    return {
        "early_warning_recall_at_50km": alert_hits / alert_total if alert_total else 0.0,
        "false_alarm_rate": false_alarms / safe_total if safe_total else 0.0,
        "alert_samples": alert_total,
        "safe_samples": safe_total,
    }


def validate_with_huggingface(model: CoefficientModel) -> dict[str, float]:
    try:
        from datasets import load_dataset
    except ImportError:
        return {"hf_clusters_checked": 0, "hf_within_quartile_rate": 0.0}

    try:
        dataset = load_dataset("ProblemsByVin/failure-mileage-distribution", split="train")
    except Exception:
        return {"hf_clusters_checked": 0, "hf_within_quartile_rate": 0.0, "hf_validation_skipped": True}
    hits = checked = 0

    for row in dataset:
        if row.get("mileage_sample_size", 0) < 8:
            continue
        component = str(row.get("component_category") or row.get("component") or "")
        part = map_compdesc(component)
        if part is None:
            continue

        q1 = float(row.get("mileage_q1") or row.get("mileage_p25") or 0) * MI_TO_KM
        q3 = float(row.get("mileage_q3") or row.get("mileage_p75") or 0) * MI_TO_KM
        if q1 <= 0 or q3 <= 0:
            continue

        base = _base_interval_for_part(part)
        effective = model.effective_interval(
            torch.tensor([base]),
            ["Бензиновый"],
            ["unknown"],
            [2000],
            [1600],
            [part],
        ).item()

        checked += 1
        if q1 <= effective <= q3:
            hits += 1

    return {
        "hf_clusters_checked": checked,
        "hf_within_quartile_rate": hits / checked if checked else 0.0,
    }


def train(
    *,
    source_path: Path,
    epochs: int = 500,
    batch_size: int = 512,
    lr: float = 1e-2,
    max_complaints: int = 20_000,
    use_vpic: bool = False,
    seed: int = 42,
) -> dict:
    complaints = stratified_sample_complaints(source_path, max_complaints=max_complaints, seed=seed, use_vpic=use_vpic)
    if complaints.empty:
        raise RuntimeError("No training complaints were sampled. Download NHTSA data first.")

    points = build_training_points(complaints, use_vpic=use_vpic)
    train_points, val_points = split_points(points, seed=seed)

    model = CoefficientModel(DEFAULT_COEFFICIENTS)
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    loader = DataLoader(TrainingDataset(train_points), batch_size=batch_size, shuffle=True, collate_fn=collate_batch)

    for _ in tqdm(range(epochs), desc="Training"):
        model.train()
        for batch in loader:
            optimizer.zero_grad()
            loss = compute_loss(model, batch)
            loss.backward()
            optimizer.step()

    val_metrics = evaluate(model, val_points)
    hf_metrics = validate_with_huggingface(model)
    coefficients = model.coefficients_dict()

    metadata = {
        "epochs": epochs,
        "train_points": len(train_points),
        "val_points": len(val_points),
        "complaints": len(complaints),
        "unique_makes": int(complaints["make"].nunique()),
        "unique_models": int(complaints[["make", "model"]].drop_duplicates().shape[0]),
        **val_metrics,
        **hf_metrics,
    }
    save_coefficients(coefficients, metadata=metadata)
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(metadata, indent=2, ensure_ascii=False), encoding="utf-8")
    return metadata


def main() -> None:
    parser = argparse.ArgumentParser(description="Train maintenance coefficients on NHTSA complaints.")
    parser.add_argument("--data-path", type=Path, default=DATA_DIR / "FLAT_CMPL.txt")
    parser.add_argument("--download", action="store_true", help="Download NHTSA data before training.")
    parser.add_argument("--epochs", type=int, default=500)
    parser.add_argument("--batch-size", type=int, default=512)
    parser.add_argument("--lr", type=float, default=1e-2)
    parser.add_argument("--max-complaints", type=int, default=20_000)
    parser.add_argument("--use-vpic", action="store_true", help="Enrich vehicle specs via VPIC API.")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if args.download or not args.data_path.exists():
        args.data_path = download_cmpl()

    metadata = train(
        source_path=args.data_path,
        epochs=args.epochs,
        batch_size=args.batch_size,
        lr=args.lr,
        max_complaints=args.max_complaints,
        use_vpic=args.use_vpic,
        seed=args.seed,
    )
    print(json.dumps(metadata, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
