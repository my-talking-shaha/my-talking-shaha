import 'package:flutter/material.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

abstract final class DashboardFormatters {
  static String number(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  static String engineType(AppLocalizations l10n, String value) {
    return switch (value.toLowerCase()) {
      'gasoline' => l10n.gasoline,
      'diesel' => l10n.diesel,
      'hybrid' => l10n.hybrid,
      'phev' => l10n.phev,
      'electric' => l10n.electric,
      _ => value,
    };
  }

  static String engineSpecification(Vehicle vehicle) {
    final power = vehicle.enginePowerHp;
    if (power != null) return '$power hp';

    final volume = vehicle.engineVolumeLiters;
    if (volume != null) return '${_engineVolume(volume)} L';

    return 'Unknown';
  }

  static String relativeDate(BuildContext context, DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(local.year, local.month, local.day);
    final difference = today.difference(eventDay).inDays;
    final materialLocalizations = MaterialLocalizations.of(context);

    if (difference == 0) {
      return materialLocalizations.formatTimeOfDay(
        TimeOfDay.fromDateTime(local),
        alwaysUse24HourFormat: true,
      );
    }
    if (difference == 1) {
      return materialLocalizations.formatMediumDate(local).toUpperCase();
    }

    return materialLocalizations.formatShortMonthDay(local).toUpperCase();
  }

  static String _engineVolume(double volumeLiters) {
    final value = volumeLiters.toString();
    return value.endsWith('.0') ? value.substring(0, value.length - 2) : value;
  }
}
