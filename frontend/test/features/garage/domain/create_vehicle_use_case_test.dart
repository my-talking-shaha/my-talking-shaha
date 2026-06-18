import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/garage/domain/entities/garage_vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';
import 'package:frontend/features/garage/domain/use_cases/create_vehicle.dart';
import 'package:frontend/features/garage/domain/validation/vehicle_draft_validator.dart';

void main() {
  group('CreateVehicle', () {
    test('trims text fields and creates a vehicle', () async {
      final repository = _FakeGarageRepository();
      final useCase = CreateVehicle(repository);

      final vehicle = await useCase(
        const VehicleDraft(
          brand: '  Lada ',
          model: ' 2106 ',
          year: 1998,
          color: ' blue ',
          currentMileageKm: 124580,
          engineType: ' gasoline ',
        ),
      );

      expect(vehicle.brand, 'Lada');
      expect(vehicle.model, '2106');
      expect(vehicle.color, 'blue');
      expect(vehicle.currentMileageKm, 124580);
      expect(vehicle.engineType, 'gasoline');
      expect(repository.createdDrafts.single.brand, 'Lada');
    });

    test('rejects missing required values and invalid numbers', () async {
      final useCase = CreateVehicle(_FakeGarageRepository());

      expect(
        () => useCase(
          const VehicleDraft(
            brand: ' ',
            model: '',
            year: 1700,
            currentMileageKm: -1,
            engineType: '',
          ),
        ),
        throwsA(isA<GarageValidationException>()),
      );
    });
  });
}

class _FakeGarageRepository implements GarageRepository {
  final List<VehicleDraft> createdDrafts = [];

  @override
  Future<GarageVehicle> addVehicle(VehicleDraft draft) async {
    createdDrafts.add(draft);
    return GarageVehicle(
      id: 'vehicle_${createdDrafts.length}',
      brand: draft.brand,
      model: draft.model,
      year: draft.year,
      color: draft.color,
      currentMileageKm: draft.currentMileageKm,
      engineType: draft.engineType,
      photoUrl: null,
      status: GarageVehicleStatus.unknown,
      activeWarningsCount: 0,
    );
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {}

  @override
  Future<List<GarageVehicle>> getVehicles() async => const [];
}
