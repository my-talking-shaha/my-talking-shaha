import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

abstract final class HistoryEventFormUtils {
  static const int _maxEventCost = 100000;
  static const double _maxRechargeEnergyKwh = 500;

  static String titleFor(
    HistoryEventType type, {
    AppLocalizations? l10n,
    bool isElectricVehicle = false,
  }) {
    if (l10n == null) {
      return switch (type) {
        HistoryEventType.fuel =>
          isElectricVehicle ? 'New recharge' : 'New refueling',
        HistoryEventType.maintenance => 'New maintenance',
        HistoryEventType.trip => 'New trip',
      };
    }

    return switch (type) {
      HistoryEventType.fuel =>
        isElectricVehicle ? l10n.newRecharge : l10n.newRefueling,
      HistoryEventType.maintenance => l10n.newMaintenance,
      HistoryEventType.trip => l10n.newTrip,
    };
  }

  static String editTitleFor(
    HistoryEventType type, {
    AppLocalizations? l10n,
    bool isElectricVehicle = false,
  }) {
    if (l10n == null) {
      return switch (type) {
        HistoryEventType.fuel =>
          isElectricVehicle ? 'Edit recharge' : 'Edit refueling',
        HistoryEventType.maintenance => 'Edit maintenance',
        HistoryEventType.trip => 'Edit trip',
      };
    }

    return switch (type) {
      HistoryEventType.fuel =>
        isElectricVehicle ? l10n.editRecharge : l10n.editRefueling,
      HistoryEventType.maintenance => l10n.editMaintenance,
      HistoryEventType.trip => l10n.editTrip,
    };
  }

  static String formatDateTime(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year}, '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }

  static String? validateMileage(
    String? value, {
    required int minimumMileageKm,
    AppLocalizations? l10n,
  }) {
    final positiveError = validatePositiveInt(
      value,
      label: l10n?.mileage ?? 'Mileage',
      l10n: l10n,
    );
    if (positiveError != null) return positiveError;

    if (int.parse(value!) < minimumMileageKm) {
      return l10n?.mileageAtLeastKm(minimumMileageKm) ??
          'Must be at least $minimumMileageKm km';
    }
    return null;
  }

  static String? validateTripStart(
    String? value, {
    required int minimumMileageKm,
    AppLocalizations? l10n,
  }) {
    final positiveError = validatePositiveInt(
      value,
      label: l10n?.start ?? 'Start mileage',
      l10n: l10n,
    );
    if (positiveError != null) return positiveError;

    if (int.parse(value!) < minimumMileageKm) {
      return l10n?.atLeastKm(minimumMileageKm) ??
          'At least $minimumMileageKm km';
    }
    return null;
  }

  static String? validateTripEnd(
    String? value, {
    required String startMileage,
    AppLocalizations? l10n,
  }) {
    final positiveError = validatePositiveInt(
      value,
      label: l10n?.end ?? 'End mileage',
      l10n: l10n,
    );
    if (positiveError != null) return positiveError;

    final start = int.tryParse(startMileage);
    final end = int.parse(value!);
    if (start != null && end <= start) {
      return l10n?.mustExceedStart ?? 'Must exceed start';
    }
    return null;
  }

  static String? validatePositiveInt(
    String? value, {
    required String label,
    AppLocalizations? l10n,
    int? maxValue,
  }) {
    final number = int.tryParse(value ?? '');
    if (number == null || number <= 0) {
      return l10n?.fieldMustBePositive(label) ?? '$label must be positive';
    }
    if (maxValue != null && number > maxValue) {
      final formattedMax = _formatCompactNumber(maxValue);
      return l10n?.fieldMax(formattedMax) ?? 'Max $formattedMax';
    }
    return null;
  }

  static String? validateStoredCost(String? value, {AppLocalizations? l10n}) {
    return validatePositiveInt(
      value,
      label: l10n?.cost ?? 'Cost',
      l10n: l10n,
      maxValue: _maxEventCost,
    );
  }

  static String? validateFuelLiters(String? value, {AppLocalizations? l10n}) {
    final liters = parseDecimal(value);
    if (liters == null) return l10n?.fuelLitersInvalidNumber ?? 'Enter number';
    if (liters <= 0) return l10n?.fuelLitersMustBePositive ?? '> 0 L';
    if (liters > 100) return l10n?.fuelLitersMax(100) ?? 'Max 100 L';
    return null;
  }

  static String? validateEnergyKwh(String? value, {AppLocalizations? l10n}) {
    final energyKwh = parseDecimal(value);
    if (energyKwh == null) {
      return l10n?.energyKwhInvalidNumber ?? 'Enter energy';
    }
    if (energyKwh <= 0) {
      return l10n?.energyKwhMustBePositive ?? 'Must be > 0 kWh';
    }
    if (energyKwh > _maxRechargeEnergyKwh) {
      final formattedMax = _formatCompactNumber(_maxRechargeEnergyKwh);
      return l10n?.energyKwhMax(formattedMax) ?? 'Max $formattedMax kWh';
    }
    return null;
  }

  static String _formatCompactNumber(num value) {
    final text = value is int
        ? value.toString()
        : value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
    final parts = text.split('.');
    final digits = parts.first;
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[index]);
    }
    if (parts.length == 1 || parts.last.isEmpty) return buffer.toString();
    return '$buffer.${parts.last}';
  }

  static double? parseDecimal(String? value) {
    final normalized = value?.trim().replaceAll(',', '.');
    if (normalized == null || normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  static String? validateRequired(
    String? value, {
    required String label,
    AppLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.fieldIsRequired(label) ?? '$label is required';
    }
    return null;
  }

  static List<String> parseCommaSeparated(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String? trimToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
