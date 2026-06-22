import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';

abstract final class DashboardUtils {
  static Vehicle? findVehicle(List<Vehicle> vehicles, String id) {
    for (final vehicle in vehicles) {
      if (vehicle.id == id) return vehicle;
    }
    return null;
  }

  static String formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  static String engineLabel(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return 'Unknown';
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  static String engineVolumeLabel(double volumeLiters) {
    final value = volumeLiters.toString();
    return value.endsWith('.0') ? value.substring(0, value.length - 2) : value;
  }

  static String eventSubtitle(HistoryEvent event) {
    return switch (event.details) {
      FuelDetails(:final liters, :final fuelType) => '$liters L • $fuelType',
      MaintenanceDetails(:final description) => description,
      TripDetails(:final route, :final distanceKm) => [
        if (route != null && route.trim().isNotEmpty) route.trim(),
        '${formatNumber(distanceKm)} km',
      ].join(' • '),
    };
  }

  static String relativeDate(DateTime occurredAt) {
    final local = occurredAt.toLocal();
    final now = DateTime.now();
    final eventDay = DateTime(local.year, local.month, local.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(eventDay).inDays;

    if (difference == 0) {
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    if (difference == 1) return 'YESTERDAY';

    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${local.day} ${months[local.month - 1]}';
  }
}
