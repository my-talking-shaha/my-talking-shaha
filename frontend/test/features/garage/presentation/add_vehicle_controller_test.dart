import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/garage/domain/entities/garage_vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';
import 'package:frontend/features/garage/presentation/controllers/add_vehicle_controller.dart';

void main() {
  group('AddVehicleController', () {
    test('reports every required field when submitting an empty form',
        () async {
      final repository = _RecordingGarageRepository();
      final controller = AddVehicleController(repository: repository);

      final createdVehicle = await controller.submit();

      expect(createdVehicle, isNull);
      expect(repository.createdDrafts, isEmpty);
      expect(
        controller.state.fieldErrors.keys,
        containsAll([
          'brand',
          'model',
          'year',
          'currentMileageKm',
          'engineType',
        ]),
      );
    });

    test('does not call the repository when required fields are invalid',
        () async {
      final repository = _RecordingGarageRepository();
      final controller = AddVehicleController(repository: repository);

      controller
        ..updateBrand('')
        ..updateModel('')
        ..updateYear('1800')
        ..updateCurrentMileage('-10')
        ..updateEngineType('');

      final createdVehicle = await controller.submit();

      expect(createdVehicle, isNull);
      expect(repository.createdDrafts, isEmpty);
      expect(
        controller.state.fieldErrors.keys,
        containsAll(
            ['brand', 'model', 'year', 'currentMileageKm', 'engineType']),
      );
    });

    test('prevents duplicate submit while create is already in flight',
        () async {
      final pendingCreate = Completer<GarageVehicle>();
      final repository =
          _RecordingGarageRepository(pendingCreate: pendingCreate);
      final controller = AddVehicleController(repository: repository);

      controller
        ..updateBrand('Lada')
        ..updateModel('2106')
        ..updateYear('1998')
        ..updateColor('blue')
        ..updateCurrentMileage('124580')
        ..updateEngineType('gasoline');

      final firstSubmit = controller.submit();
      final duplicateSubmit = controller.submit();

      expect(repository.createdDrafts, hasLength(1));
      await expectLater(duplicateSubmit, completion(isNull));

      pendingCreate.complete(
        _vehicle(id: 'vehicle_1', draft: repository.createdDrafts.single),
      );

      final createdVehicle = await firstSubmit;

      expect(createdVehicle?.id, 'vehicle_1');
      expect(repository.createdDrafts, hasLength(1));
    });
  });
}

GarageVehicle _vehicle({
  required String id,
  required VehicleDraft draft,
}) {
  return GarageVehicle(
    id: id,
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

final class _RecordingGarageRepository implements GarageRepository {
  _RecordingGarageRepository({this.pendingCreate});

  final Completer<GarageVehicle>? pendingCreate;
  final List<VehicleDraft> createdDrafts = [];

  @override
  Future<List<GarageVehicle>> getVehicles() async => const [];

  @override
  Future<GarageVehicle> addVehicle(VehicleDraft draft) {
    createdDrafts.add(draft);
    return pendingCreate?.future ??
        Future.value(_vehicle(id: 'vehicle_1', draft: draft));
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {}
}
