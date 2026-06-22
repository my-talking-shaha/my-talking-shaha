import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/garage/domain/entities/garage_vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';
import 'package:frontend/features/garage/presentation/controllers/add_vehicle_controller.dart';

void main() {
  group('AddVehicleController', () {
    test(
      'reports every required field when submitting an empty form',
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
            'engineSpecification',
          ]),
        );
      },
    );

    test(
      'does not call the repository when required fields are invalid',
      () async {
        final repository = _RecordingGarageRepository();
        final controller = AddVehicleController(repository: repository);

        controller
          ..updateBrand('')
          ..updateModel('')
          ..updateYear('1800')
          ..updateCurrentMileage('-10')
          ..updateEngineType('')
          ..updateEngineSpecification('0');

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
            'engineSpecification',
          ]),
        );
      },
    );

    test(
      'prevents duplicate submit while create is already in flight',
      () async {
        final pendingCreate = Completer<GarageVehicle>();
        final repository = _RecordingGarageRepository(
          pendingCreate: pendingCreate,
        );
        final controller = AddVehicleController(repository: repository);

        controller
          ..updateBrand('Lada')
          ..updateModel('2106')
          ..updateYear('1998')
          ..updateColor('blue')
          ..updateCurrentMileage('124580')
          ..updateEngineType('gasoline')
          ..updateEngineSpecification('1.6');

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
      },
    );

    test('loads an existing vehicle and submits updates', () async {
      final repository = _RecordingGarageRepository();
      final controller = AddVehicleController(repository: repository);

      controller.loadVehicle(
        _vehicle(
          id: 'vehicle_123',
          draft: const VehicleDraft(
            brand: 'Lada',
            model: '2106',
            year: 1998,
            color: 'blue',
            currentMileageKm: 124580,
            engineType: 'gasoline',
            engineVolumeLiters: 1.6,
            enginePowerHp: null,
            vin: 'XTA21060012345678',
          ),
        ),
      );
      expect(controller.state.engineSpecification, '1.6');
      expect(controller.state.vin, 'XTA21060012345678');
      controller
        ..updateModel('2107')
        ..updateColor('green')
        ..updateVin('');

      final updatedVehicle = await controller.submit();

      expect(updatedVehicle?.id, 'vehicle_123');
      expect(updatedVehicle?.model, '2107');
      expect(updatedVehicle?.color, 'green');
      expect(updatedVehicle?.vin, isNull);
      expect(repository.createdDrafts.single.model, '2107');
    });

    test(
      'normalizes and saves engine specifications and optional VIN',
      () async {
        final repository = _RecordingGarageRepository();
        final controller = AddVehicleController(repository: repository);

        controller
          ..updateBrand('Lada')
          ..updateModel('2106')
          ..updateYear('1998')
          ..updateCurrentMileage('124580')
          ..updateEngineType('gasoline')
          ..updateEngineSpecification('1,6')
          ..updateVin(' xta21060012345678 ');

        final vehicle = await controller.submit();

        expect(vehicle?.engineVolumeLiters, 1.6);
        expect(vehicle?.enginePowerHp, isNull);
        expect(vehicle?.vin, 'XTA21060012345678');
      },
    );

    test('stores power only for an electric engine', () async {
      final repository = _RecordingGarageRepository();
      final controller = AddVehicleController(repository: repository);

      controller
        ..updateBrand('Tesla')
        ..updateModel('Model 3')
        ..updateYear('2024')
        ..updateCurrentMileage('1000')
        ..updateEngineType('electric')
        ..updateEngineSpecification('283');

      final vehicle = await controller.submit();

      expect(vehicle?.engineVolumeLiters, isNull);
      expect(vehicle?.enginePowerHp, 283);
    });

    test('rejects VIN values that are not exactly 17 characters', () async {
      final repository = _RecordingGarageRepository();
      final controller = AddVehicleController(repository: repository);

      controller
        ..updateBrand('Lada')
        ..updateModel('2106')
        ..updateYear('1998')
        ..updateCurrentMileage('124580')
        ..updateEngineType('gasoline')
        ..updateEngineSpecification('1.6')
        ..updateVin('SHORTVIN');

      expect(await controller.submit(), isNull);
      expect(controller.state.fieldErrors['vin'], isNotNull);
      expect(repository.createdDrafts, isEmpty);
    });
  });
}

GarageVehicle _vehicle({required String id, required VehicleDraft draft}) {
  return GarageVehicle(
    id: id,
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

  @override
  Future<GarageVehicle> updateVehicle(String vehicleId, VehicleDraft draft) {
    createdDrafts.add(draft);
    return Future.value(_vehicle(id: vehicleId, draft: draft));
  }
}
