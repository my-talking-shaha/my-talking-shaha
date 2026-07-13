import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/colors.dart';
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

  static DashboardEventPresentation from(HistoryEventType type) {
    return switch (type) {
      HistoryEventType.fuel => const DashboardEventPresentation(
        assetPath: 'assets/icons/events/gas.svg',
        iconColor: DashboardColors.warning,
        backgroundColor: DashboardColors.fuelEventBackground,
      ),
      HistoryEventType.maintenance => const DashboardEventPresentation(
        assetPath: 'assets/icons/events/spanner.svg',
        iconColor: DashboardColors.success,
        backgroundColor: DashboardColors.maintenanceEventBackground,
      ),
      HistoryEventType.trip => const DashboardEventPresentation(
        assetPath: 'assets/icons/events/trip.svg',
        iconColor: DashboardColors.primaryLight,
        backgroundColor: DashboardColors.surfaceHighest,
      ),
    };
  }
}
