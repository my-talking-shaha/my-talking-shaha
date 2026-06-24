import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_latest_events.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_vehicle_summary.dart';
import 'package:frontend/features/parts/presentation/widgets/maintenance_forecast_card.dart';

final class DashboardContent extends StatelessWidget {
  const DashboardContent({required this.dashboard, super.key});

  final DashboardData dashboard;

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
          DashboardVehicleSummary(vehicle: dashboard.vehicle),
          const SizedBox(height: AppSpacing.xxxl),
          MaintenanceForecastCard(parts: dashboard.maintenanceParts),
          const SizedBox(height: AppSpacing.xl),
          DashboardLatestEvents(
            vehicleId: dashboard.vehicle.id,
            events: dashboard.recentEvents,
          ),
        ],
      ),
    );
  }
}
