sealed class EventDetails {
  const EventDetails();
}

class FuelDetails extends EventDetails {
  final int cost;
  final int liters;
  final String fuelType;

  FuelDetails({
    required this.cost,
    required this.liters,
    required this.fuelType,
  });
}

class MaintenanceDetails extends EventDetails {
  final String description;
  final int? cost;
  final List<String>? replacedParts;
  final List<String>? photoUrls;

  MaintenanceDetails({
    required this.description,
    this.cost,
    this.replacedParts,
    this.photoUrls,
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
