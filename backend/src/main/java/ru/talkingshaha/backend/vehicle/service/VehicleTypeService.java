package ru.talkingshaha.backend.vehicle.service;

import java.util.List;

import org.springframework.stereotype.Service;

import ru.talkingshaha.backend.vehicle.dto.FuelTypeOption;
import ru.talkingshaha.backend.vehicle.model.FuelType;

@Service
public class VehicleTypeService {

    private static final List<FuelType> FUEL_TYPES = List.of(
            FuelType.PETROL_92,
            FuelType.PETROL_95,
            FuelType.PETROL_98,
            FuelType.PETROL_100,
            FuelType.DIESEL);

    private static final List<FuelType> ENGINE_TYPES = List.of(
            FuelType.GASOLINE,
            FuelType.DIESEL,
            FuelType.HYBRID,
            FuelType.PHEV,
            FuelType.ELECTRIC);

    public List<FuelTypeOption> fuelTypes() {
        return FUEL_TYPES.stream().map(FuelTypeOption::of).toList();
    }

    public List<FuelTypeOption> engineTypes() {
        return ENGINE_TYPES.stream().map(FuelTypeOption::of).toList();
    }
}
