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
      photoUrl: null,
      status: 'unknown',
      activeWarningsCount: 0,
    );

    _vehicles.add(vehicle);
    return vehicle;
  }

  Future<void> deleteVehicle(String vehicleId) async {
    _vehicles.removeWhere((vehicle) => vehicle.id == vehicleId);
  }
}
