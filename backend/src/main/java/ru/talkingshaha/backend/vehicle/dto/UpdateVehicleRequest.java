package ru.talkingshaha.backend.vehicle.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import ru.talkingshaha.backend.vehicle.model.FuelType;

public record UpdateVehicleRequest(
        @Size(max = 80) String brand,
        @Size(max = 120) String model,
        @Min(1900) @Max(2100) Integer productionYear,
        @Size(max = 40) String color,
        @PositiveOrZero Integer mileageKm,
        FuelType fuelType,
        @Size(max = 80) String engineDescription,
        @Size(min = 17, max = 17) String vin,
        @Size(max = 500) String photoUrl) {
}
