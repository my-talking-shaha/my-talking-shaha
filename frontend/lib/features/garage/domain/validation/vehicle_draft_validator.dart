import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';

final class VehicleDraftValidationResult {
  const VehicleDraftValidationResult(this.fieldErrors);

  final Map<String, String> fieldErrors;

  bool get isValid => fieldErrors.isEmpty;
}

final class GarageValidationException implements Exception {
  const GarageValidationException(this.fieldErrors);

  final Map<String, String> fieldErrors;

  @override
  String toString() => 'GarageValidationException($fieldErrors)';
}

abstract final class VehicleDraftValidator {
  static const int _firstSupportedCarYear = 1900;

  static VehicleDraftValidationResult validate(VehicleDraft draft) {
    final errors = <String, String>{};
    final currentYear = DateTime.now().year;

    if (draft.brand.trim().isEmpty) {
      errors['brand'] = 'Enter a brand';
    }
    if (draft.model.trim().isEmpty) {
      errors['model'] = 'Enter a model';
    }
    if (draft.year < _firstSupportedCarYear || draft.year > currentYear) {
      errors['year'] = 'Enter a production year from 1900 to $currentYear';
    }
    if (draft.currentMileageKm < 0) {
      errors['currentMileageKm'] = 'Mileage cannot be negative';
    }
    if (draft.engineType.trim().isEmpty) {
      errors['engineType'] = 'Select an engine type';
    }
    final isElectric = draft.engineType.trim().toLowerCase() == 'electric';
    final hasVolume = draft.engineVolumeLiters != null;
    final hasPower = draft.enginePowerHp != null;
    if (hasVolume && hasPower) {
      errors['engineSpecification'] =
          'Enter either engine volume or power output';
    } else if (isElectric) {
      if (draft.enginePowerHp == null || draft.enginePowerHp! <= 0) {
        errors['engineSpecification'] =
            'Power output must be greater than zero';
      }
    } else if (draft.engineVolumeLiters == null ||
        draft.engineVolumeLiters! <= 0) {
      errors['engineSpecification'] = 'Engine volume must be greater than zero';
    }
    if (draft.vin case final vin?
        when vin.trim().isNotEmpty && vin.trim().length != 17) {
      errors['vin'] = 'VIN must contain exactly 17 characters';
    }

    return VehicleDraftValidationResult(Map.unmodifiable(errors));
  }
}
