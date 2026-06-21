import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';
import 'package:frontend/features/garage/domain/use_cases/create_vehicle.dart';
import 'package:frontend/features/garage/domain/use_cases/update_vehicle.dart';
import 'package:frontend/features/garage/domain/validation/vehicle_draft_validator.dart';
import 'package:frontend/features/garage/presentation/state/add_vehicle_state.dart';

final class AddVehicleController {
  AddVehicleController({required GarageRepository repository})
    : _createVehicle = CreateVehicle(repository),
      _updateVehicle = UpdateVehicle(repository);

  final CreateVehicle _createVehicle;
  final UpdateVehicle _updateVehicle;
  String? _editingVehicleId;

  AddVehicleState state = const AddVehicleState();

  bool get isEditing => _editingVehicleId != null;

  void loadVehicle(Vehicle vehicle) {
    _editingVehicleId = vehicle.id;
    state = AddVehicleState(
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.year.toString(),
      color: vehicle.color ?? '',
      currentMileage: vehicle.currentMileageKm.toString(),
      engineType: vehicle.engineType,
      engineSpecification: vehicle.engineType == 'electric'
          ? vehicle.enginePowerHp?.toString() ?? ''
          : vehicle.engineVolumeLiters?.toString() ?? '',
      vin: vehicle.vin ?? '',
    );
  }

  void updateBrand(String value) {
    state = state.copyWith(
      brand: value,
      fieldErrors: _withoutError('brand'),
      clearErrorMessage: true,
    );
  }

  void updateModel(String value) {
    state = state.copyWith(
      model: value,
      fieldErrors: _withoutError('model'),
      clearErrorMessage: true,
    );
  }

  void updateYear(String value) {
    state = state.copyWith(
      year: value,
      fieldErrors: _withoutError('year'),
      clearErrorMessage: true,
    );
  }

  void updateColor(String value) {
    state = state.copyWith(color: value, clearErrorMessage: true);
  }

  void updateCurrentMileage(String value) {
    state = state.copyWith(
      currentMileage: value,
      fieldErrors: _withoutError('currentMileageKm'),
      clearErrorMessage: true,
    );
  }

  void updateEngineType(String value) {
    final didChange = state.engineType != value;
    state = state.copyWith(
      engineType: value,
      engineSpecification: didChange ? '' : state.engineSpecification,
      fieldErrors: _withoutErrors(['engineType', 'engineSpecification']),
      clearErrorMessage: true,
    );
  }

  void updateEngineSpecification(String value) {
    state = state.copyWith(
      engineSpecification: value,
      fieldErrors: _withoutError('engineSpecification'),
      clearErrorMessage: true,
    );
  }

  void updateVin(String value) {
    state = state.copyWith(
      vin: value,
      fieldErrors: _withoutError('vin'),
      clearErrorMessage: true,
    );
  }

  Future<Vehicle?> submit() async {
    if (state.isSubmitting) {
      return null;
    }

    final draft = _draftFromState();
    if (draft == null) {
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      fieldErrors: const {},
      clearErrorMessage: true,
    );

    try {
      final vehicleId = _editingVehicleId;
      final vehicle = vehicleId == null
          ? await _createVehicle(draft)
          : await _updateVehicle(vehicleId, draft);
      state = state.copyWith(isSubmitting: false);
      return vehicle;
    } on GarageValidationException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        fieldErrors: error.fieldErrors,
        errorMessage: 'Check the vehicle details',
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: isEditing
            ? 'Could not update the vehicle'
            : 'Could not save the vehicle',
      );
      return null;
    }
  }

  VehicleDraft? _draftFromState() {
    final errors = <String, String>{};
    final parsedYear = int.tryParse(state.year.trim());
    final parsedMileage = int.tryParse(state.currentMileage.trim());
    final isElectric = state.engineType.trim().toLowerCase() == 'electric';
    final parsedEngineVolume = isElectric
        ? null
        : double.tryParse(
            state.engineSpecification.trim().replaceAll(',', '.'),
          );
    final parsedEnginePower = isElectric
        ? int.tryParse(state.engineSpecification.trim())
        : null;

    if (state.brand.trim().isEmpty) {
      errors['brand'] = 'Enter a brand';
    }
    if (state.model.trim().isEmpty) {
      errors['model'] = 'Enter a model';
    }
    if (parsedYear == null) {
      errors['year'] = 'Enter a production year';
    }
    if (parsedMileage == null) {
      errors['currentMileageKm'] = 'Enter current mileage';
    }
    if (state.engineType.trim().isEmpty) {
      errors['engineType'] = 'Select an engine type';
    }
    if (isElectric && parsedEnginePower == null) {
      errors['engineSpecification'] = 'Enter power output';
    } else if (!isElectric && parsedEngineVolume == null) {
      errors['engineSpecification'] = 'Enter engine volume';
    }

    if (parsedYear == null ||
        parsedMileage == null ||
        (isElectric ? parsedEnginePower == null : parsedEngineVolume == null)) {
      state = state.copyWith(
        fieldErrors: errors,
        errorMessage: 'Check the vehicle details',
      );
      return null;
    }

    final draft = VehicleDraft(
      brand: state.brand,
      model: state.model,
      year: parsedYear,
      color: state.color,
      currentMileageKm: parsedMileage,
      engineType: state.engineType,
      engineVolumeLiters: parsedEngineVolume,
      enginePowerHp: parsedEnginePower,
      vin: state.vin,
    );
    final normalizedDraft = draft.trimmed();
    final validationResult = VehicleDraftValidator.validate(normalizedDraft);
    errors.addAll(validationResult.fieldErrors);

    if (errors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: Map.unmodifiable(errors),
        errorMessage: 'Check the vehicle details',
      );
      return null;
    }

    return normalizedDraft;
  }

  Map<String, String> _withoutError(String field) {
    final errors = Map<String, String>.from(state.fieldErrors)..remove(field);
    return Map.unmodifiable(errors);
  }

  Map<String, String> _withoutErrors(Iterable<String> fields) {
    final errors = Map<String, String>.from(state.fieldErrors);
    for (final field in fields) {
      errors.remove(field);
    }
    return Map.unmodifiable(errors);
  }
}
