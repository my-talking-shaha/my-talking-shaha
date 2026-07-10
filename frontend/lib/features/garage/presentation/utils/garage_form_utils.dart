import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/garage/presentation/controllers/power_output_unit_controller.dart';
import 'package:frontend/features/garage/presentation/state/add_vehicle_state.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

const standardGarageVehicleColors = [
  'White',
  'Black',
  'Silver',
  'Grey',
  'Red',
  'Blue',
  'Green',
  'Yellow',
  'Orange',
  'Brown',
  'Beige',
  'Gold',
  'Purple',
];

List<String> garageBrandOptions({
  required List<String>? brands,
  required String selectedBrand,
}) {
  final options = <String>[...?brands];
  final normalizedSelectedBrand = selectedBrand.trim();
  if (normalizedSelectedBrand.isNotEmpty &&
      !options.contains(normalizedSelectedBrand)) {
    options.add(normalizedSelectedBrand);
  }

  return List.unmodifiable(options);
}

String? garageBrandErrorText(
  AppLocalizations l10n,
  AsyncValue<List<String>> brands,
  AddVehicleState state,
) {
  final fieldError = localizedGarageVehicleError(
    l10n,
    state.fieldErrors['brand'],
  );
  if (fieldError != null) {
    return fieldError;
  }

  if (brands.hasError) {
    return 'Could not load brands';
  }

  return null;
}

PowerOutputUnit garagePowerOutputUnit(
  AsyncValue<PowerOutputUnit> persistedUnit,
  String fallbackValue,
) {
  return persistedUnit.whenOrNull(data: (unit) => unit) ??
      PowerOutputUnit.fromValue(fallbackValue);
}

String? canonicalGarageVehicleColor(String color) {
  final normalizedColor = color.trim().toLowerCase();
  if (normalizedColor.isEmpty) {
    return null;
  }

  for (final standardColor in standardGarageVehicleColors) {
    if (standardColor.toLowerCase() == normalizedColor) {
      return standardColor;
    }
  }

  return null;
}

String localizedGarageVehicleColor(AppLocalizations l10n, String color) {
  return switch (color) {
    'White' => l10n.vehicleColorWhite,
    'Black' => l10n.vehicleColorBlack,
    'Silver' => l10n.vehicleColorSilver,
    'Grey' => l10n.vehicleColorGrey,
    'Red' => l10n.vehicleColorRed,
    'Blue' => l10n.vehicleColorBlue,
    'Green' => l10n.vehicleColorGreen,
    'Yellow' => l10n.vehicleColorYellow,
    'Orange' => l10n.vehicleColorOrange,
    'Brown' => l10n.vehicleColorBrown,
    'Beige' => l10n.vehicleColorBeige,
    'Gold' => l10n.vehicleColorGold,
    'Purple' => l10n.vehicleColorPurple,
    _ => color,
  };
}

String localizedGarageEngineType(AppLocalizations l10n, String value) {
  return switch (value) {
    'gasoline' => l10n.gasoline,
    'diesel' => l10n.diesel,
    'hybrid' => l10n.hybrid,
    'phev' => l10n.phev,
    'electric' => l10n.electric,
    _ => value,
  };
}

String? localizedGarageVehicleError(AppLocalizations l10n, String? message) {
  if (message == null) return null;

  final yearMatch = RegExp(
    r'Enter a production year from 1900 to (\d+)',
  ).firstMatch(message);
  if (yearMatch != null) {
    return l10n.enterProductionYearRange(int.parse(yearMatch.group(1)!));
  }

  return switch (message) {
    'Check the vehicle details' => l10n.checkVehicleDetails,
    'Could not update the vehicle' => l10n.couldNotUpdateVehicle,
    'Could not save the vehicle' => l10n.couldNotSaveVehicle,
    'Enter a brand' => l10n.enterBrand,
    'Enter a model' => l10n.enterModel,
    'Enter a production year' => l10n.enterProductionYear,
    'Mileage cannot be negative' => l10n.mileageCannotBeNegative,
    'Enter current mileage' => l10n.enterCurrentMileage,
    'Select an engine type' => l10n.selectEngineType,
    'Enter either engine volume or power output' =>
      l10n.enterEngineSpecification,
    'Power output must be greater than zero' => l10n.powerOutputPositive,
    'Engine volume must be greater than zero' => l10n.engineVolumePositive,
    'Enter power output' => l10n.enterPowerOutput,
    'Enter engine volume' => l10n.enterEngineVolume,
    'VIN must contain exactly 17 characters' => l10n.vinLengthError,
    _ => message,
  };
}
