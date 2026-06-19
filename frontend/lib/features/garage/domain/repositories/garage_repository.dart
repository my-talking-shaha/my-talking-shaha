import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';

abstract interface class GarageRepository {
  Future<List<Vehicle>> getVehicles();

  Future<Vehicle> addVehicle(VehicleDraft draft);

  Future<Vehicle> updateVehicle(String vehicleId, VehicleDraft draft);

  Future<void> deleteVehicle(String vehicleId);
}
