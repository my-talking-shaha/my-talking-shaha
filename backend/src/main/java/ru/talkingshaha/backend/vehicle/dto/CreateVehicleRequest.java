package ru.talkingshaha.backend.vehicle.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import ru.talkingshaha.backend.vehicle.model.FuelType;

public record CreateVehicleRequest(
        @NotBlank @Size(max = 80) String brand,
        @NotBlank @Size(max = 120) String model,
        @NotNull @Min(1900) @Max(2100) Integer productionYear,
        @Size(max = 40) String color,
        @NotNull @PositiveOrZero Integer mileageKm,
        @NotNull FuelType fuelType,
        @Size(max = 80) String engineDescription,
        @Size(min = 17, max = 17) String vin,
        @Size(max = 500) String photoUrl) {}