import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';

abstract interface class PartsDatasource {
  Future<List<VehiclePart>> getParts({required String vehicleId});

  Future<int?> getCurrentVehicleMileageKm({required String vehicleId});
}
