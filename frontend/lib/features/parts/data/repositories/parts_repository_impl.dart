import 'package:frontend/features/parts/data/datasources/parts_datasource.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/domain/repositories/parts_repository.dart';
import 'package:frontend/features/parts/domain/use_cases/calculate_part_resource.dart';

final class PartsRepositoryImpl implements PartsRepository {
  PartsRepositoryImpl(
    this._datasource, {
    CalculatePartResource? calculatePartResource,
  }) : _calculatePartResource =
           calculatePartResource ?? CalculatePartResource();

  final PartsDatasource _datasource;
  final CalculatePartResource _calculatePartResource;

  @override
  Future<List<VehiclePart>> getParts({required String vehicleId}) async {
    final parts = await _datasource.getParts(vehicleId: vehicleId);
    final currentMileageKm = await _datasource.getCurrentVehicleMileageKm(
      vehicleId: vehicleId,
    );

    if (currentMileageKm == null) {
      return parts;
    }

    return parts
        .map(
          (part) => _calculatePartResource(
            part: part,
            currentVehicleMileageKm: currentMileageKm,
          ),
        )
        .toList(growable: false);
  }
}
