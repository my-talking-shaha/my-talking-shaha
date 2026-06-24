import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';

final vehicleMileageProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  vehicleId,
) async {
  final vehicles = await ref.watch(garageControllerProvider.future);
  for (final vehicle in vehicles) {
    if (vehicle.id == vehicleId) {
      return vehicle.currentMileageKm;
    }
  }
  return 0;
});
