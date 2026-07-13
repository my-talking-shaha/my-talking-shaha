"""Tests for learned maintenance coefficients."""

from datetime import datetime, timedelta

from ml.coefficients import DEFAULT_COEFFICIENTS, load_coefficients, need_score, save_coefficients
from ml.component_mapping import map_compdesc
from ml.models import CarSpec, Usage
from ml.predict import predict_maintenance
from ml.spec_utils import normalize_displacement_cc
from ml.vehicle_sync import map_fuel_type, row_to_car_spec


def test_load_coefficients_fallback(tmp_path):
    missing = tmp_path / "missing.json"
    coeffs = load_coefficients(missing)
    assert coeffs == DEFAULT_COEFFICIENTS


def test_save_and_load_coefficients(tmp_path):
    path = tmp_path / "coefficients.json"
    custom = dict(DEFAULT_COEFFICIENTS)
    custom["hybrid.brake_pads"] = 1.7
    save_coefficients(custom, path)
    loaded = load_coefficients(path)
    assert loaded["hybrid.brake_pads"] == 1.7


def test_need_score_monotonic_with_mileage():
    scores = [
        need_score(
            mileage,
            10_000,
            engine_type="Бензиновый",
            displacement=2000,
            transmission="Автомат",
            weight=1500,
            part="engine_oil",
        )
        for mileage in (1000, 5000, 9000, 12_000)
    ]
    assert scores[0] <= scores[1] <= scores[2] <= scores[3]


def test_displacement_normalization():
    assert normalize_displacement_cc(2.0) == 2000
    assert normalize_displacement_cc(2000) == 2000


def test_component_mapping_examples():
    assert map_compdesc("ENGINE AND ENGINE COOLING:COOLING SYSTEM:RADIATOR") == "coolant"
    assert map_compdesc("SERVICE BRAKES, HYDRAULIC:FOUNDATION COMPONENTS") == "brake_pads"
    assert map_compdesc("POWER TRAIN:AUTOMATIC TRANSMISSION") == "transmission_oil"


def test_vehicle_sync_from_row():
    spec = row_to_car_spec(
        {
            "make": "TOYOTA",
            "model": "CAMRY",
            "year": 2018,
            "fuel_type": "GS",
            "drive_train": "FWD",
            "num_cyls": 4,
            "compdesc": "ENGINE",
            "description": "",
        },
        use_vpic=False,
    )
    assert spec.engine_type == "Бензиновый"
    assert spec.transmission == "Автомат"


def test_map_fuel_type_codes():
    assert map_fuel_type("DS") == "Дизельный"
    assert map_fuel_type("HE") == "Гибридный"


def test_predict_maintenance_still_returns_twelve_components():
    spec = CarSpec("petrol", 2.0, "automatic", 1500)
    usage = Usage(600, 60, 1500, 150, 25, datetime.now() - timedelta(days=30))
    result = predict_maintenance(spec, usage)
    assert len(result) == 12
    assert all(0 <= item["maintenance need"] <= 1 for item in result)
