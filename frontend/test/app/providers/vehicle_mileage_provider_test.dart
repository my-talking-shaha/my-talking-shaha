import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/providers/vehicle_mileage_provider.dart';
import 'package:frontend/features/garage/data/datasources/in_memory_garage_datasource.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';

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

Future<ProviderContainer> _containerWithMileage(int mileageKm) async {
  final garageDatasource = InMemoryGarageDatasource();
  await garageDatasource.addVehicle(
    VehicleDraft(
      brand: 'Lada',
      model: '2106',
      year: 1998,
      currentMileageKm: mileageKm,
      engineType: 'gasoline',
      engineVolumeLiters: 1.6,
      enginePowerHp: null,
    ),
  );

  return ProviderContainer(
    overrides: [garageDatasourceProvider.overrideWithValue(garageDatasource)],
  );
}
