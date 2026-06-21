import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_latest_events.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_vehicle_summary.dart';
import 'package:frontend/features/dashboard/presentation/widgets/maintenance_forecast_placeholder.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';

final class DashboardContent extends StatelessWidget {
  const DashboardContent({
    required this.vehicle,
    required this.eventsState,
    super.key,
  });

  final Vehicle vehicle;
  final AsyncValue<List<HistoryEvent>> eventsState;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          DashboardVehicleSummary(vehicle: vehicle),
          const SizedBox(height: AppSpacing.xxxl),
          const DashboardSectionHeader(title: 'MAINTENANCE FORECAST'),
          const SizedBox(height: AppSpacing.md),
          const MaintenanceForecastPlaceholder(),
          const SizedBox(height: AppSpacing.xxxl),
          DashboardLatestEvents(
            vehicleId: vehicle.id,
            eventsState: eventsState,
          ),
        ],
      ),
    );
  }
}
