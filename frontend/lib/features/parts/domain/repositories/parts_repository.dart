import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';

abstract interface class PartsRepository {
  Future<List<VehiclePart>> getParts({required String vehicleId});
}
