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
  static const int _firstCarYear = 1886;

  static VehicleDraftValidationResult validate(VehicleDraft draft) {
    final errors = <String, String>{};
    final currentYear = DateTime.now().year;

    if (draft.brand.trim().isEmpty) {
      errors['brand'] = 'Enter a brand';
    }
    if (draft.model.trim().isEmpty) {
      errors['model'] = 'Enter a model';
    }
    if (draft.year < _firstCarYear || draft.year > currentYear) {
      errors['year'] = 'Enter a realistic production year';
    }
    if (draft.currentMileageKm < 0) {
      errors['currentMileageKm'] = 'Mileage cannot be negative';
    }
    if (draft.engineType.trim().isEmpty) {
      errors['engineType'] = 'Select an engine type';
    }

    return VehicleDraftValidationResult(Map.unmodifiable(errors));
  }
}
