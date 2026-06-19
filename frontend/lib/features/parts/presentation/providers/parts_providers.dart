import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/parts/data/datasources/in_memory_parts_datasource.dart';
import 'package:frontend/features/parts/data/repositories/parts_repository_impl.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/domain/repositories/parts_repository.dart';
import 'package:frontend/features/parts/domain/use_cases/calculate_part_resource.dart';
import 'package:frontend/features/parts/domain/use_cases/get_vehicle_parts.dart';

final inMemoryPartsDatasourceProvider =
    Provider<InMemoryPartsDatasource>((ref) {
  return InMemoryPartsDatasource();
});

final calculatePartResourceProvider = Provider<CalculatePartResource>((ref) {
  return CalculatePartResource();
});

final partsRepositoryProvider = Provider<PartsRepository>((ref) {
  return PartsRepositoryImpl(
    ref.watch(inMemoryPartsDatasourceProvider),
    calculatePartResource: ref.watch(calculatePartResourceProvider),
  );
});

final getVehiclePartsProvider = Provider<GetVehicleParts>((ref) {
  return GetVehicleParts(ref.watch(partsRepositoryProvider));
});

final vehiclePartsProvider =
    FutureProvider.autoDispose.family<List<VehiclePart>, String>((
  ref,
  vehicleId,
) {
  return ref.watch(getVehiclePartsProvider).call(vehicleId: vehicleId);
});
