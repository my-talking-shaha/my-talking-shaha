package ru.talkingshaha.backend.vehicle.model;

public enum FuelType {
    PETROL_92("Petrol (92)"),
    PETROL_95("Petrol (95)"),
    PETROL_98("Petrol (98)"),
    PETROL_100("Petrol (100)"),
    GASOLINE("Gasoline"),
    DIESEL("Diesel"),
    HYBRID("Hybrid"),
    ELECTRIC("Electric"),
    PHEV("PHEV"),
    OTHER("Other");

    private final String label;

    FuelType(String label) {
        this.label = label;
    }

    public String label() {
        return label;
    }
}
