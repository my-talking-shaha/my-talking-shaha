import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/providers/vehicle_mileage_provider.dart';
import 'package:frontend/features/garage/data/datasources/in_memory_garage_datasource.dart';
import 'package:frontend/features/garage/di/garage_providers.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';

void main() {
  test('uses mileage from the selected vehicle', () async {
    final container = await _containerWithMileage(120000);
    addTearDown(container.dispose);

    expect(await _readMileage(container, 'vehicle_1'), 120000);
  });

  test('returns zero when the selected vehicle does not exist', () async {
    final container = await _containerWithMileage(120000);
    addTearDown(container.dispose);

    expect(await _readMileage(container, 'missing'), 0);
  });

  test('uses engine type from the selected vehicle', () async {
    final container = await _containerWithVehicle(
      _vehicleDraft(mileageKm: 120000, engineType: 'electric'),
    );
    addTearDown(container.dispose);

    expect(await _readEngineType(container, 'vehicle_1'), 'electric');
    expect(await _readEngineType(container, 'missing'), isNull);
  });

  test('leaves hybrid engine type distinct from electric', () async {
    final container = await _containerWithVehicle(
      _vehicleDraft(mileageKm: 120000, engineType: 'hybrid'),
    );
    addTearDown(container.dispose);

    expect(await _readEngineType(container, 'vehicle_1'), 'hybrid');
  });

  test('uses refreshed garage state after invalidation', () async {
    final garageDatasource = InMemoryGarageDatasource();
    await garageDatasource.addVehicle(_vehicleDraft(mileageKm: 120000));
    final container = ProviderContainer(
      overrides: [garageDatasourceProvider.overrideWithValue(garageDatasource)],
    );
    addTearDown(container.dispose);

    expect(await _readMileage(container, 'vehicle_1'), 120000);

    await garageDatasource.updateVehicle(
      'vehicle_1',
      _vehicleDraft(mileageKm: 125000),
    );

    expect(await _readMileage(container, 'vehicle_1'), 120000);

    container.invalidate(garageControllerProvider);
    container.invalidate(vehicleMileageProvider('vehicle_1'));

    expect(await _readMileage(container, 'vehicle_1'), 125000);
  });
}

Future<int> _readMileage(ProviderContainer container, String vehicleId) async {
  final provider = vehicleMileageProvider(vehicleId);
  final subscription = container.listen(provider, (_, _) {});
  try {
    return await container.read(provider.future);
  } finally {
    subscription.close();
  }
}

Future<String?> _readEngineType(
  ProviderContainer container,
  String vehicleId,
) async {
  final provider = vehicleEngineTypeProvider(vehicleId);
  final subscription = container.listen(provider, (_, _) {});
  try {
    return await container.read(provider.future);
  } finally {
    subscription.close();
  }
}

Future<ProviderContainer> _containerWithMileage(int mileageKm) async {
  return _containerWithVehicle(_vehicleDraft(mileageKm: mileageKm));
}

Future<ProviderContainer> _containerWithVehicle(VehicleDraft draft) async {
  final garageDatasource = InMemoryGarageDatasource();
  await garageDatasource.addVehicle(draft);

  return ProviderContainer(
    overrides: [garageDatasourceProvider.overrideWithValue(garageDatasource)],
  );
}

VehicleDraft _vehicleDraft({
  required int mileageKm,
  String engineType = 'gasoline',
}) {
  return VehicleDraft(
    brand: 'Lada',
    model: '2106',
    year: 1998,
    currentMileageKm: mileageKm,
    engineType: engineType,
    engineVolumeLiters: engineType == 'electric' ? null : 1.6,
    enginePowerHp: engineType == 'electric' ? 120 : null,
  );
}
