import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/garage/data/datasources/garage_api_datasource.dart';
import 'package:frontend/features/garage/data/datasources/garage_datasource.dart';
import 'package:frontend/features/garage/data/datasources/in_memory_garage_datasource.dart';
import 'package:frontend/features/garage/data/repositories/garage_repository_impl.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';
import 'package:frontend/features/garage/domain/use_cases/delete_vehicle.dart';
import 'package:frontend/features/garage/domain/use_cases/get_garage_vehicles.dart';
import 'package:frontend/features/garage/presentation/controllers/add_vehicle_controller.dart';
import 'package:frontend/features/garage/presentation/controllers/garage_controller.dart';

final inMemoryGarageDatasourceProvider = Provider<InMemoryGarageDatasource>((
  ref,
) {
  return InMemoryGarageDatasource();
});

final garageApiDatasourceProvider = Provider<GarageApiDatasource>((ref) {
  return GarageApiDatasource(ref.watch(dioProvider));
});

final garageDatasourceProvider = Provider<GarageDatasource>((ref) {
  return ref.watch(garageApiDatasourceProvider);
});

final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  return GarageRepositoryImpl(ref.watch(garageDatasourceProvider));
});

final getGarageVehiclesProvider = Provider<GetGarageVehicles>((ref) {
  return GetGarageVehicles(ref.watch(garageRepositoryProvider));
});

final deleteVehicleProvider = Provider<DeleteVehicle>((ref) {
  return DeleteVehicle(ref.watch(garageRepositoryProvider));
});

final garageControllerProvider =
    AsyncNotifierProvider<GarageController, List<Vehicle>>(
  GarageController.new,
);

final addVehicleControllerProvider = Provider.autoDispose<AddVehicleController>(
  (ref) =>
      AddVehicleController(repository: ref.watch(garageRepositoryProvider)),
);
