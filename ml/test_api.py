"""Tests for maintenance prediction API."""

from datetime import datetime, timedelta

from fastapi.testclient import TestClient

from ml.api import app
from ml.predict import CarSpec, Usage, predict_maintenance

client = TestClient(app)
USAGE = {
    "total_distance_km": 600,
    "average_speed": 60,
    "altitude_gain": 1500,
    "total_trips": 150,
    "median_trip_duration": 25,
    "last_maintenance_date": (datetime.now() - timedelta(days=30)).isoformat(),
}


def test_predict_maintenance_returns_scores():
    spec = CarSpec("petrol", 2.0, "automatic", 1500)
    usage = Usage(600, 60, 1500, 150, 25, datetime.now() - timedelta(days=30))
    result = predict_maintenance(spec, usage)

    assert len(result) == 12
    assert result[0]["component"] == "Engine Oil"
    assert all(0 <= item["maintenance need"] <= 1 for item in result)


def test_predict_endpoint_with_manual_spec():
    response = client.post(
        "/api/v1/predict",
        json={
            "spec": {"engine_type": "petrol", "displacement": 2.0, "transmission": "automatic", "weight": 1500},
            "usage": USAGE,
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert len(body) == 12
    assert body[0]["component"] == "Engine Oil"
    assert all(0 <= item["maintenance need"] <= 1 for item in body)


def test_predict_endpoint_with_unknown_modification_id():
    response = client.post("/api/v1/predict", json={"spec": {"modification_id": "unknown-id"}, "usage": USAGE})
    assert response.status_code == 404


def test_health_endpoint():
    assert client.get("/health").json() == {"status": "ok"}
