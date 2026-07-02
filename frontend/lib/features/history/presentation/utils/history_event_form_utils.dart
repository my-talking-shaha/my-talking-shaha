import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

abstract final class HistoryEventFormUtils {
  static String titleFor(HistoryEventType type, [AppLocalizations? l10n]) {
    if (l10n == null) {
      return switch (type) {
        HistoryEventType.fuel => 'New refueling',
        HistoryEventType.maintenance => 'New maintenance',
        HistoryEventType.trip => 'New trip',
      };
    }

    return switch (type) {
      HistoryEventType.fuel => l10n.newRefueling,
      HistoryEventType.maintenance => l10n.newMaintenance,
      HistoryEventType.trip => l10n.newTrip,
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
  }) {
    final number = int.tryParse(value ?? '');
    if (number == null || number <= 0) {
      return l10n?.fieldMustBePositive(label) ?? '$label must be positive';
    }
    return null;
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
