final class LiveTripSession {
  const LiveTripSession({
    required this.vehicleId,
    required this.vehicleName,
    required this.startMileageKm,
    required this.startedAt,
  });

  final String vehicleId;
  final String vehicleName;
  final int startMileageKm;
  final DateTime startedAt;

  Duration elapsedAt(DateTime now) {
    final elapsed = now.difference(startedAt);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  @override
  bool operator ==(Object other) {
    return other is LiveTripSession &&
        other.vehicleId == vehicleId &&
        other.vehicleName == vehicleName &&
        other.startMileageKm == startMileageKm &&
        other.startedAt == startedAt;
  }

  @override
  int get hashCode =>
      Object.hash(vehicleId, vehicleName, startMileageKm, startedAt);
}
