import 'package:frontend/features/parts/data/datasources/parts_datasource.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';

final class InMemoryPartsDatasource implements PartsDatasource {
  static final Map<String, int> _currentMileageByVehicle = {
    'vehicle_1': 105000,
    'vehicle_2': 72800,
    'vehicle_123': 105000,
    'vehicle_456': 72800,
  };

  static final Map<String, List<VehiclePart>> _partsByVehicle = {
    'vehicle_1': [
      VehiclePart(
        id: 'part_engine_oil_vehicle_1',
        vehicleId: 'vehicle_1',
        name: 'Engine oil',
        catalogKey: 'engine_oil',
        installedAt: DateTime.utc(2026, 6, 8, 11),
        installedAtMileageKm: 100000,
        lifetimeKm: 10000,
      ),
      VehiclePart(
        id: 'part_front_pads_vehicle_1',
        vehicleId: 'vehicle_1',
        name: 'Front brake pads',
        catalogKey: 'brake_pads',
        installedAt: DateTime.utc(2026, 5, 20, 11),
        installedAtMileageKm: 95800,
        lifetimeKm: 10000,
      ),
      VehiclePart(
        id: 'part_timing_belt_vehicle_1',
        vehicleId: 'vehicle_1',
        name: 'Timing belt',
        catalogKey: 'timing_belt',
        installedAt: DateTime.utc(2025, 12, 1, 11),
        installedAtMileageKm: 95000,
        lifetimeKm: 10000,
      ),
      VehiclePart(
        id: 'part_cabin_filter_vehicle_1',
        vehicleId: 'vehicle_1',
        name: 'Cabin filter',
        catalogKey: 'cabin_filter',
        installedAt: DateTime.utc(2026, 6, 1, 11),
        installedAtMileageKm: 103500,
        lifetimeKm: null,
      ),
    ],
    'vehicle_2': [
      VehiclePart(
        id: 'part_engine_oil_vehicle_2',
        vehicleId: 'vehicle_2',
        name: 'Engine oil',
        catalogKey: 'engine_oil',
        installedAt: DateTime.utc(2026, 6, 10, 10),
        installedAtMileageKm: 70000,
        lifetimeKm: 10000,
      ),
      VehiclePart(
        id: 'part_timing_belt_vehicle_2',
        vehicleId: 'vehicle_2',
        name: 'Timing belt',
        catalogKey: 'timing_belt',
        installedAt: DateTime.utc(2025, 10, 4, 9),
        installedAtMileageKm: 52000,
        lifetimeKm: 60000,
      ),
      VehiclePart(
        id: 'part_spark_plugs_vehicle_2',
        vehicleId: 'vehicle_2',
        name: 'Spark plugs',
        catalogKey: 'spark_plugs',
        installedAt: DateTime.utc(2026, 4, 18, 12),
        installedAtMileageKm: 65000,
        lifetimeKm: 30000,
      ),
    ],
    'vehicle_123': [
      VehiclePart(
        id: 'part_engine_oil_vehicle_123',
        vehicleId: 'vehicle_123',
        name: 'Engine oil',
        catalogKey: 'engine_oil',
        installedAt: DateTime.utc(2026, 6, 8, 11),
        installedAtMileageKm: 100000,
        lifetimeKm: 10000,
      ),
      VehiclePart(
        id: 'part_front_pads_vehicle_123',
        vehicleId: 'vehicle_123',
        name: 'Front brake pads',
        catalogKey: 'brake_pads',
        installedAt: DateTime.utc(2026, 5, 20, 11),
        installedAtMileageKm: 95800,
        lifetimeKm: 10000,
      ),
      VehiclePart(
        id: 'part_battery_vehicle_123',
        vehicleId: 'vehicle_123',
        name: 'Battery',
        catalogKey: 'battery',
        installedAt: DateTime.utc(2025, 12, 1, 11),
        installedAtMileageKm: 94000,
        lifetimeKm: 10000,
      ),
      VehiclePart(
        id: 'part_cabin_filter_vehicle_123',
        vehicleId: 'vehicle_123',
        name: 'Cabin filter',
        catalogKey: 'cabin_filter',
        installedAt: DateTime.utc(2026, 6, 1, 11),
        installedAtMileageKm: 103500,
        lifetimeKm: null,
      ),
    ],
    'vehicle_456': [
      VehiclePart(
        id: 'part_engine_oil_vehicle_456',
        vehicleId: 'vehicle_456',
        name: 'Engine oil',
        catalogKey: 'engine_oil',
        installedAt: DateTime.utc(2026, 6, 10, 10),
        installedAtMileageKm: 70000,
        lifetimeKm: 10000,
      ),
      VehiclePart(
        id: 'part_timing_belt_vehicle_456',
        vehicleId: 'vehicle_456',
        name: 'Timing belt',
        catalogKey: 'timing_belt',
        installedAt: DateTime.utc(2025, 10, 4, 9),
        installedAtMileageKm: 52000,
        lifetimeKm: 60000,
      ),
      VehiclePart(
        id: 'part_spark_plugs_vehicle_456',
        vehicleId: 'vehicle_456',
        name: 'Spark plugs',
        catalogKey: 'spark_plugs',
        installedAt: DateTime.utc(2026, 4, 18, 12),
        installedAtMileageKm: 65000,
        lifetimeKm: 30000,
      ),
    ],
  };

  @override
  Future<List<VehiclePart>> getParts({required String vehicleId}) async {
    return List<VehiclePart>.unmodifiable(
      _partsByVehicle[vehicleId] ?? const [],
    );
  }

  @override
  Future<int?> getCurrentVehicleMileageKm({required String vehicleId}) async {
    return _currentMileageByVehicle[vehicleId];
  }
}
