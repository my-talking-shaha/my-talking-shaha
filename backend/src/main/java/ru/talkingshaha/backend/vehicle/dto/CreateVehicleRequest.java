package ru.talkingshaha.backend.vehicle.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import io.swagger.v3.oas.annotations.media.Schema;
import ru.talkingshaha.backend.vehicle.model.FuelType;

public record CreateVehicleRequest(
        @Schema(example = "Lada")
        @NotBlank(message = "must not be blank")
        @Size(max = 80, message = "must contain at most 80 characters")
        String brand,
        @Schema(example = "2106")
        @NotBlank(message = "must not be blank")
        @Size(max = 120, message = "must contain at most 120 characters")
        String model,
        @Schema(example = "2002")
        @NotNull(message = "must be provided")
        @Min(value = 1900, message = "must be greater than or equal to 1900")
        @Max(value = 2100, message = "must be less than or equal to 2100")
        Integer productionYear,
        @Schema(example = "green")
        @Size(max = 40, message = "must contain at most 40 characters")
        String color,
        @Schema(example = "10000")
        @NotNull(message = "must be provided")
        @PositiveOrZero(message = "must be greater than or equal to 0")
        Integer mileageKm,
        @Schema(example = "GASOLINE")
        @NotNull(message = "must be provided")
        FuelType fuelType,
        @Schema(example = "1.6 L")
        @Size(max = 80, message = "must contain at most 80 characters")
        String engineDescription,
        @Schema(example = "XTA21060012345678")
        @Size(min = 17, max = 17, message = "must contain exactly 17 characters")
        String vin,
        @Schema(example = "https://example.com/car.jpg")
        @Size(max = 500, message = "must contain at most 500 characters")
        String photoUrl) {}