import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/domain/repositories/parts_repository.dart';

final class GetVehicleParts {
  const GetVehicleParts(this._repository);

  final PartsRepository _repository;

  Future<List<VehiclePart>> call({required String vehicleId}) {
    return _repository.getParts(vehicleId: vehicleId);
  }
}
