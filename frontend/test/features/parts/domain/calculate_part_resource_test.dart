import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/domain/use_cases/calculate_part_resource.dart';

void main() {
  group('CalculatePartResource', () {
    test('computes remaining kilometers, percent, and threshold status', () {
      final useCase = CalculatePartResource();

      final ok = useCase(
        part: _part(lifetimeKm: 10000, installedAtMileageKm: 100000),
        currentVehicleMileageKm: 105000,
      );
      final warning = useCase(
        part: _part(lifetimeKm: 10000, installedAtMileageKm: 100000),
        currentVehicleMileageKm: 109200,
      );
      final critical = useCase(
        part: _part(lifetimeKm: 10000, installedAtMileageKm: 100000),
        currentVehicleMileageKm: 111000,
      );

      expect(ok.remainingKm, 5000);
      expect(ok.remainingPercent, 50);
      expect(ok.status, PartResourceStatus.ok);

      expect(warning.remainingKm, 800);
      expect(warning.remainingPercent, 8);
      expect(warning.status, PartResourceStatus.warning);

      expect(critical.remainingKm, -1000);
      expect(critical.remainingPercent, -10);
      expect(critical.status, PartResourceStatus.critical);
    });

    test('marks parts without lifetime as unknown', () {
      final useCase = CalculatePartResource();

      final resource = useCase(
        part: _part(lifetimeKm: null, installedAtMileageKm: 100000),
        currentVehicleMileageKm: 105000,
      );

      expect(resource.remainingKm, isNull);
      expect(resource.remainingPercent, isNull);
      expect(resource.status, PartResourceStatus.unknown);
    });
  });
}

VehiclePart _part({
  required int? lifetimeKm,
  required int installedAtMileageKm,
}) {
  return VehiclePart(
    id: 'part_engine_oil',
    vehicleId: 'vehicle_123',
    name: 'Engine oil',
    catalogKey: 'engine_oil',
    installedAt: DateTime.utc(2026, 6, 8, 11),
    installedAtMileageKm: installedAtMileageKm,
    lifetimeKm: lifetimeKm,
  );
}
