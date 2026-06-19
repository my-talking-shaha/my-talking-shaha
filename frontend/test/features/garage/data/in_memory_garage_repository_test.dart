import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/garage/data/datasources/in_memory_garage_datasource.dart';
import 'package:frontend/features/garage/data/repositories/garage_repository_impl.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';

void main() {
  group('GarageRepositoryImpl with in-memory datasource', () {
    test('creates, lists, and deletes vehicles in runtime memory', () async {
      final repository = GarageRepositoryImpl(InMemoryGarageDatasource());

      expect(await repository.getVehicles(), isEmpty);

      final firstVehicle = await repository.addVehicle(
        const VehicleDraft(
          brand: 'Lada',
          model: '2106',
          year: 1998,
          currentMileageKm: 124580,
          engineType: 'gasoline',
        ),
      );
      final secondVehicle = await repository.addVehicle(
        const VehicleDraft(
          brand: 'VAZ',
          model: '2107',
          year: 2005,
          color: 'green',
          currentMileageKm: 89000,
          engineType: 'diesel',
        ),
      );

      final vehicles = await repository.getVehicles();

      expect(vehicles, hasLength(2));
      expect(vehicles.map((vehicle) => vehicle.id), [
        firstVehicle.id,
        secondVehicle.id,
      ]);

      await repository.deleteVehicle(firstVehicle.id);

      expect(await repository.getVehicles(), [secondVehicle]);
    });

    test('does not persist vehicles across datasource instances', () async {
      final firstRuntimeRepository = GarageRepositoryImpl(
        InMemoryGarageDatasource(),
      );
      await firstRuntimeRepository.addVehicle(
        const VehicleDraft(
          brand: 'Lada',
          model: '2106',
          year: 1998,
          currentMileageKm: 124580,
          engineType: 'gasoline',
        ),
      );

      final secondRuntimeRepository = GarageRepositoryImpl(
        InMemoryGarageDatasource(),
      );

      expect(await secondRuntimeRepository.getVehicles(), isEmpty);
    });

    test('updates an existing vehicle while preserving the id', () async {
      final repository = GarageRepositoryImpl(InMemoryGarageDatasource());
      final vehicle = await repository.addVehicle(
        const VehicleDraft(
          brand: 'Lada',
          model: '2106',
          year: 1998,
          currentMileageKm: 124580,
          engineType: 'gasoline',
        ),
      );

      final updatedVehicle = await repository.updateVehicle(
        vehicle.id,
        const VehicleDraft(
          brand: 'Lada',
          model: '2107',
          year: 2005,
          color: 'green',
          currentMileageKm: 130000,
          engineType: 'diesel',
        ),
      );

      expect(updatedVehicle.id, vehicle.id);
      expect(updatedVehicle.model, '2107');
      expect(updatedVehicle.color, 'green');
      expect(await repository.getVehicles(), [updatedVehicle]);
    });
  });
}
