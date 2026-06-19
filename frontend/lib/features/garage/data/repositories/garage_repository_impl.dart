import 'package:frontend/features/garage/data/datasources/in_memory_garage_datasource.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';

final class GarageRepositoryImpl implements GarageRepository {
  const GarageRepositoryImpl(this._datasource);

  final InMemoryGarageDatasource _datasource;

  @override
  Future<Vehicle> addVehicle(VehicleDraft draft) {
    return _datasource.addVehicle(draft);
  }

  @override
  Future<void> deleteVehicle(String vehicleId) {
    return _datasource.deleteVehicle(vehicleId);
  }

  @override
  Future<List<Vehicle>> getVehicles() {
    return _datasource.getVehicles();
  }

  @override
  Future<Vehicle> updateVehicle(String vehicleId, VehicleDraft draft) {
    return _datasource.updateVehicle(vehicleId, draft);
  }
}
