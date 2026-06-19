import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';
import 'package:frontend/features/garage/domain/validation/vehicle_draft_validator.dart';

final class UpdateVehicle {
  const UpdateVehicle(this._repository);

  final GarageRepository _repository;

  Future<Vehicle> call(String vehicleId, VehicleDraft draft) {
    final trimmedDraft = draft.trimmed();
    final validationResult = VehicleDraftValidator.validate(trimmedDraft);

    if (!validationResult.isValid) {
      throw GarageValidationException(validationResult.fieldErrors);
    }

    return _repository.updateVehicle(vehicleId, trimmedDraft);
  }
}
