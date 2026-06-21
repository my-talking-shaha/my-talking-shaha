import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';

final class InMemoryGarageDatasource {
  final List<Vehicle> _vehicles = [];
  int _nextVehicleNumber = 1;

  Future<List<Vehicle>> getVehicles() async {
    return List.unmodifiable(_vehicles);
  }

  Future<Vehicle> addVehicle(VehicleDraft draft) async {
    final normalizedDraft = draft.trimmed();
    final vehicle = Vehicle(
      id: 'vehicle_${_nextVehicleNumber++}',
      brand: normalizedDraft.brand,
      model: normalizedDraft.model,
      year: normalizedDraft.year,
      color: normalizedDraft.color,
      currentMileageKm: normalizedDraft.currentMileageKm,
      engineType: normalizedDraft.engineType,
      engineVolumeLiters: normalizedDraft.engineVolumeLiters,
      enginePowerHp: normalizedDraft.enginePowerHp,
      vin: normalizedDraft.vin,
      photoUrl: null,
      status: 'unknown',
      activeWarningsCount: 0,
    );

    _vehicles.add(vehicle);
    return vehicle;
  }

  Future<Vehicle> updateVehicle(String vehicleId, VehicleDraft draft) async {
    final index = _vehicles.indexWhere((vehicle) => vehicle.id == vehicleId);
    if (index == -1) {
      throw StateError('Vehicle not found');
    }

    final normalizedDraft = draft.trimmed();
    final currentVehicle = _vehicles[index];
    final updatedVehicle = currentVehicle.copyWith(
      brand: normalizedDraft.brand,
      model: normalizedDraft.model,
      year: normalizedDraft.year,
      color: normalizedDraft.color,
      currentMileageKm: normalizedDraft.currentMileageKm,
      engineType: normalizedDraft.engineType,
      engineVolumeLiters: normalizedDraft.engineVolumeLiters,
      clearEngineVolume: normalizedDraft.engineVolumeLiters == null,
      enginePowerHp: normalizedDraft.enginePowerHp,
      clearEnginePower: normalizedDraft.enginePowerHp == null,
      vin: normalizedDraft.vin,
      clearVin: normalizedDraft.vin == null,
    );

    _vehicles[index] = updatedVehicle;
    return updatedVehicle;
  }

  Future<void> deleteVehicle(String vehicleId) async {
    _vehicles.removeWhere((vehicle) => vehicle.id == vehicleId);
  }
}
