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
          engineVolumeLiters: 1.6,
          enginePowerHp: null,
          vin: ' xta21060012345678 ',
        ),
      );

      expect(vehicle.brand, 'Lada');
      expect(vehicle.model, '2106');
      expect(vehicle.color, 'blue');
      expect(vehicle.currentMileageKm, 124580);
      expect(vehicle.engineType, 'gasoline');
      expect(vehicle.engineVolumeLiters, 1.6);
      expect(vehicle.enginePowerHp, isNull);
      expect(vehicle.vin, 'XTA21060012345678');
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
            engineVolumeLiters: 0,
            enginePowerHp: null,
          ),
        ),
        throwsA(isA<GarageValidationException>()),
      );
    });

    test('rejects assigning both volume and power to one vehicle', () async {
      final useCase = CreateVehicle(_FakeGarageRepository());

      expect(
        () => useCase(
          const VehicleDraft(
            brand: 'Lada',
            model: '2106',
            year: 1998,
            currentMileageKm: 124580,
            engineType: 'gasoline',
            engineVolumeLiters: 1.6,
            enginePowerHp: 75,
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
      engineVolumeLiters: draft.engineVolumeLiters,
      enginePowerHp: draft.enginePowerHp,
      vin: draft.vin,
      photoUrl: null,
      status: GarageVehicleStatus.unknown,
      activeWarningsCount: 0,
    );
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {}

  @override
  Future<List<GarageVehicle>> getVehicles() async => const [];

  @override
  Future<GarageVehicle> updateVehicle(
    String vehicleId,
    VehicleDraft draft,
  ) async {
    return addVehicle(draft);
  }
}
