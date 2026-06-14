package ru.talkingshaha.backend.vehicle.dto;

import java.util.UUID;
import ru.talkingshaha.backend.vehicle.model.FuelType;

public record VehicleResponse(
        UUID id,
        String brand,
        String model,
        Integer productionYear,
        String color,
        Integer mileageKm,
        FuelType fuelType,
        String engineDescription,
        String vin,
        String photoUrl) {}