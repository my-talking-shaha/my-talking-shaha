import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/parts/data/datasources/in_memory_parts_datasource.dart';
import 'package:frontend/features/parts/data/repositories/parts_repository_impl.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';

void main() {
  group('PartsRepositoryImpl with in-memory datasource', () {
    test('returns only mocked parts for the requested vehicle id', () async {
      final repository = PartsRepositoryImpl(InMemoryPartsDatasource());

      final firstGarageVehicleParts = await repository.getParts(
        vehicleId: 'vehicle_1',
      );
      final shahaParts = await repository.getParts(vehicleId: 'vehicle_123');
      final otherVehicleParts = await repository.getParts(
        vehicleId: 'vehicle_456',
      );
      final missingVehicleParts = await repository.getParts(
        vehicleId: 'vehicle_without_parts',
      );

      expect(firstGarageVehicleParts, isNotEmpty);
      expect(shahaParts, isNotEmpty);
      expect(otherVehicleParts, isNotEmpty);
      expect(missingVehicleParts, isEmpty);
      expect(
        firstGarageVehicleParts.map((part) => part.vehicleId),
        everyElement('vehicle_1'),
      );
      expect(
        shahaParts.map((part) => part.vehicleId),
        everyElement('vehicle_123'),
      );
      expect(
        otherVehicleParts.map((part) => part.vehicleId),
        everyElement('vehicle_456'),
      );
      expect(
        shahaParts
            .map((part) => part.id)
            .toSet()
            .intersection(otherVehicleParts.map((part) => part.id).toSet()),
        isEmpty,
      );
      expect(shahaParts.map((part) => part.name), contains('Engine oil'));
      expect(
        shahaParts.map((part) => part.status),
        contains(PartResourceStatus.unknown),
      );
    });
  });
}
