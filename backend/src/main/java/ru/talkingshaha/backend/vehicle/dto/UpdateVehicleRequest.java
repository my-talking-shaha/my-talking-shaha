package ru.talkingshaha.backend.vehicle.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import io.swagger.v3.oas.annotations.media.Schema;
import ru.talkingshaha.backend.vehicle.model.FuelType;

public record UpdateVehicleRequest(
        @Schema(example = "Lada")
        @Size(max = 80, message = "must contain at most 80 characters")
        String brand,
        @Schema(example = "2106")
        @Size(max = 120, message = "must contain at most 120 characters")
        String model,
        @Schema(example = "2002")
        @Min(value = 1900, message = "must be greater than or equal to 1900")
        @Max(value = 2100, message = "must be less than or equal to 2100")
        Integer productionYear,
        @Schema(example = "blue")
        @Size(max = 40, message = "must contain at most 40 characters")
        String color,
        @Schema(example = "10500")
        @PositiveOrZero(message = "must be greater than or equal to 0")
        Integer mileageKm,
        @Schema(example = "GASOLINE")
        FuelType fuelType,
        @Schema(example = "1.6 L")
        @Size(max = 80, message = "must contain at most 80 characters")
        String engineDescription,
        @Schema(example = "XTA21060012345678")
        @Size(min = 17, max = 17, message = "must contain exactly 17 characters")
        String vin,
        @Schema(example = "https://example.com/new-car.jpg")
        @Size(max = 500, message = "must contain at most 500 characters")
        String photoUrl) {
}
