import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';

final class DeleteVehicle {
  const DeleteVehicle(this._repository);

  final GarageRepository _repository;

  Future<void> call(String vehicleId) => _repository.deleteVehicle(vehicleId);
}
