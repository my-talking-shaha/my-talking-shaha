import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_formatters.dart';
import 'package:frontend/features/dashboard/presentation/widgets/vehicle_hero_card.dart';
import 'package:frontend/features/dashboard/presentation/widgets/vehicle_metric_card.dart';
import 'package:frontend/features/dashboard/presentation/widgets/vin_card.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class DashboardVehicleSummary extends StatelessWidget {
  const DashboardVehicleSummary({required this.vehicle, super.key});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        VehicleHeroCard(vehicle: vehicle),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: VehicleMetricCard(
                label: l10n.mileage,
                value: DashboardFormatters.number(vehicle.currentMileageKm),
                suffix: 'km',
                subtitle: l10n.currentOdometer,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: VehicleMetricCard(
                label: l10n.engine,
                value: DashboardFormatters.engineSpecification(vehicle),
                subtitle: DashboardFormatters.engineType(
                  l10n,
                  vehicle.engineType,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        VinCard(vin: vehicle.vin),
      ],
    );
  }
}
