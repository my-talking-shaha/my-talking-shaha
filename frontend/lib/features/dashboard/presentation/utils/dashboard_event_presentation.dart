import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';

final class DashboardEventPresentation {
  const DashboardEventPresentation({
    required this.assetPath,
    required this.iconColor,
    required this.backgroundColor,
  });

  final String assetPath;
  final Color iconColor;
  final Color backgroundColor;

  static DashboardEventPresentation from(
    HistoryEventType type, {
    AppPalette colors = AppPalette.dark,
  }) {
    return switch (type) {
      HistoryEventType.fuel => DashboardEventPresentation(
        assetPath: 'assets/icons/events/gas.svg',
        iconColor: colors.warning,
        backgroundColor: colors.fuelEventBackground,
      ),
      HistoryEventType.maintenance => DashboardEventPresentation(
        assetPath: 'assets/icons/events/spanner.svg',
        iconColor: colors.success,
        backgroundColor: colors.maintenanceEventBackground,
      ),
      HistoryEventType.trip => DashboardEventPresentation(
        assetPath: 'assets/icons/events/trip.svg',
        iconColor: colors.primaryLight,
        backgroundColor: colors.surfaceHighest,
      ),
    };
  }
}
