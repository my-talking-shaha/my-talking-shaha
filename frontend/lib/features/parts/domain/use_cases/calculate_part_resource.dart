import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';

final class CalculatePartResource {
  VehiclePart call({
    required VehiclePart part,
    required int currentVehicleMileageKm,
  }) {
    final lifetimeKm = part.lifetimeKm;

    if (lifetimeKm == null || lifetimeKm <= 0) {
      return part.withResource(
        remainingKm: null,
        remainingPercent: null,
        status: PartResourceStatus.unknown,
      );
    }

    final usedKm = currentVehicleMileageKm - part.installedAtMileageKm;
    final remainingKm = lifetimeKm - usedKm;
    final remainingPercent = ((remainingKm / lifetimeKm) * 100).round();

    return part.withResource(
      remainingKm: remainingKm,
      remainingPercent: remainingPercent,
      status: _statusFor(remainingPercent),
    );
  }

  PartResourceStatus _statusFor(int remainingPercent) {
    if (remainingPercent <= 0) {
      return PartResourceStatus.critical;
    }

    if (remainingPercent <= 10) {
      return PartResourceStatus.warning;
    }

    return PartResourceStatus.ok;
  }
}
