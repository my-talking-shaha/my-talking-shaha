sealed class EventDetails {
  const EventDetails();
}

class FuelDetails extends EventDetails {
  final double cost;
  final double liters;
  final String fuelType;
  final bool isRecharge;

  FuelDetails({
    required this.cost,
    required this.liters,
    required this.fuelType,
    this.isRecharge = false,
  });
}

class MaintenanceDetails extends EventDetails {
  final String description;
  final double? cost;
  final List<String>? replacedParts;
  final List<String>? photoUrls;
  final int? currentMileageKm;

  MaintenanceDetails({
    required this.description,
    this.cost,
    this.replacedParts,
    this.photoUrls,
    this.currentMileageKm,
  });
}

class TripDetails extends EventDetails {
  final int startKm;
  final int endKm;
  final String? route;
  final Duration duration;

  const TripDetails({
    required this.startKm,
    required this.endKm,
    this.route,
    required this.duration,
  });

  int get distanceKm => endKm - startKm;
}
