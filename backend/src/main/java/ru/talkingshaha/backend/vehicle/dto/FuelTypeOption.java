package ru.talkingshaha.backend.vehicle.dto;

import ru.talkingshaha.backend.vehicle.model.FuelType;

public record FuelTypeOption(FuelType code, String label) {
    public static FuelTypeOption of(FuelType type) {
        return new FuelTypeOption(type, type.label());
    }
}
