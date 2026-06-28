"""FastAPI server for maintenance prediction."""

from datetime import datetime
from typing import Any

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, ConfigDict, Field

from ml.predict import CarSpec, Usage, load_car_spec, predict_maintenance

app = FastAPI(title="Maintenance Prediction API", version="1.0.0")


class UsageInput(BaseModel):
    total_distance_km: float
    average_speed: float
    altitude_gain: float
    total_trips: int
    median_trip_duration: float
    last_maintenance_date: datetime


class PredictRequest(BaseModel):
    spec: dict[str, Any]
    usage: UsageInput


class ComponentPrediction(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    component: str
    maintenance_need: float = Field(alias="maintenance need")


def _build_spec(spec: dict[str, Any]) -> CarSpec:
    if "modification_id" in spec:
        return load_car_spec(spec["modification_id"])
    return CarSpec(
        engine_type=spec["engine_type"],
        displacement=spec.get("displacement"),
        transmission=spec["transmission"],
        weight=spec["weight"],
    )


def _build_usage(usage: UsageInput) -> Usage:
    return Usage(
        total_distance_km=usage.total_distance_km,
        average_speed=usage.average_speed,
        altitude_gain=usage.altitude_gain,
        total_trips=usage.total_trips,
        median_trip_duration=usage.median_trip_duration,
        last_maintenance_date=usage.last_maintenance_date,
    )


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/api/v1/predict", response_model=list[ComponentPrediction])
def predict_endpoint(request: PredictRequest):
    try:
        return predict_maintenance(_build_spec(request.spec), _build_usage(request.usage))
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
