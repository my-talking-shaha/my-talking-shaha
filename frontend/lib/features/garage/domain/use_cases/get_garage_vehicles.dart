import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';

final class GetGarageVehicles {
  const GetGarageVehicles(this._repository);

  final GarageRepository _repository;

  Future<List<Vehicle>> call() => _repository.getVehicles();
}
