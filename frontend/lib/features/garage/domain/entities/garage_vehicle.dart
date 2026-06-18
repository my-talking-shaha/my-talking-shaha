import 'package:frontend/features/garage/domain/entities/vehicle.dart';

typedef GarageVehicle = Vehicle;

enum GarageVehicleEngineType {
  gasoline('gasoline'),
  diesel('diesel'),
  hybrid('hybrid'),
  electric('electric');

  const GarageVehicleEngineType(this.value);

  final String value;
}

abstract final class GarageVehicleStatus {
  static const ok = 'ok';
  static const warning = 'warning';
  static const critical = 'critical';
  static const unknown = 'unknown';
}
