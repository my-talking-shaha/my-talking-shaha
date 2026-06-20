import 'package:frontend/features/history/domain/history_event_type.dart';

abstract final class HistoryEventFormUtils {
  static String titleFor(HistoryEventType type) {
    return switch (type) {
      HistoryEventType.fuel => 'New refueling',
      HistoryEventType.maintenance => 'New maintenance',
      HistoryEventType.trip => 'New trip',
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
  }) {
    final positiveError = validatePositiveInt(value, label: 'Mileage');
    if (positiveError != null) return positiveError;

    if (int.parse(value!) < minimumMileageKm) {
      return 'Must be at least $minimumMileageKm km';
    }
    return null;
  }

  static String? validateTripStart(
    String? value, {
    required int minimumMileageKm,
  }) {
    final positiveError = validatePositiveInt(value, label: 'Start mileage');
    if (positiveError != null) return positiveError;

    if (int.parse(value!) < minimumMileageKm) {
      return 'At least $minimumMileageKm km';
    }
    return null;
  }

  static String? validateTripEnd(
    String? value, {
    required String startMileage,
  }) {
    final positiveError = validatePositiveInt(value, label: 'End mileage');
    if (positiveError != null) return positiveError;

    final start = int.tryParse(startMileage);
    final end = int.parse(value!);
    if (start != null && end <= start) return 'Must exceed start';
    return null;
  }

  static String? validatePositiveInt(String? value, {required String label}) {
    final number = int.tryParse(value ?? '');
    if (number == null || number <= 0) return '$label must be positive';
    return null;
  }

  static String? validateRequired(String? value, {required String label}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
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
