import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/presentation/utils/garage_vehicle_formatters.dart';
import 'package:frontend/features/garage/presentation/widgets/garage_metric_tile.dart';
import 'package:frontend/features/garage/presentation/widgets/garage_vehicle_image.dart';
import 'package:frontend/features/garage/presentation/widgets/swipe_reveal_actions.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class VehicleGarageCard extends StatelessWidget {
  const VehicleGarageCard({
    required this.vehicle,
    required this.onOpen,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Vehicle vehicle;
  final VoidCallback onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = vehicle.color == null || vehicle.color!.isEmpty
        ? '${vehicle.year} · ${garageEngineTypeLabel(l10n, vehicle.engineType)}'
        : '${vehicle.year} · ${vehicle.color} · ${garageEngineTypeLabel(l10n, vehicle.engineType)}';

    return SwipeRevealActions(
      actions: [
        if (onEdit != null)
          SwipeRevealAction(
            label: l10n.edit,
            iconPath: 'assets/icons/garage/edit.svg',
            color: context.appColors.swipeEdit,
            onPressed: onEdit!,
          ),
        if (onDelete != null)
          SwipeRevealAction(
            label: l10n.delete,
            iconPath: 'assets/icons/garage/delete.svg',
            color: context.appColors.swipeDelete,
            onPressed: onDelete!,
          ),
      ],
      child: Material(
        color: context.appColors.transparent,
        borderRadius: AppRadius.card,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          borderRadius: AppRadius.card,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: AppRadius.card,
              border: Border.all(color: context.appColors.border),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.appColors.surfaceHighest,
                  context.appColors.surface,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GarageVehicleImage(vehicle: vehicle),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.brand} ${vehicle.model}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: GarageMetricTile(
                              iconPath: 'assets/icons/garage/mileage.svg',
                              label: l10n.mileage,
                              value:
                                  '${formatGarageMileage(vehicle.currentMileageKm)} km',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: GarageMetricTile(
                              iconPath: 'assets/icons/garage/repair.svg',
                              label: l10n.service,
                              value: vehicle.activeWarningsCount > 0
                                  ? l10n.warningsCount(
                                      vehicle.activeWarningsCount,
                                    )
                                  : l10n.noIssues,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: GarageMetricTile(
                              iconPath: 'assets/icons/garage/refuel.svg',
                              label: l10n.fuel,
                              value: l10n.noData,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onOpen,
                          icon: const Icon(Icons.keyboard_arrow_right),
                          label: Text(l10n.openCockpit),
                          iconAlignment: IconAlignment.end,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
