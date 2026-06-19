import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';

final class GarageController extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() {
    return ref.watch(getGarageVehiclesProvider).call();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getGarageVehiclesProvider).call(),
    );
  }

  Future<void> deleteVehicle(String vehicleId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteVehicleProvider).call(vehicleId);
      return ref.read(getGarageVehiclesProvider).call();
    });
  }
}
