import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/presentation/metrics.dart';
import 'package:frontend/features/parts/presentation/utils/maintenance_forecast_utils.dart';
import 'package:frontend/features/parts/presentation/widgets/forecast_summary.dart';
import 'package:frontend/features/parts/presentation/widgets/maintenance_forecast_header.dart';
import 'package:frontend/features/parts/presentation/widgets/part_resource_row.dart';
import 'package:frontend/features/parts/presentation/widgets/resource_badge.dart';

final class MaintenanceForecastCard extends StatelessWidget {
  const MaintenanceForecastCard({
    required this.parts,
    this.lastUpdatedLabel,
    super.key,
  });

  final List<VehiclePart> parts;
  final String? lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final aggregatePercent = averagePartsPercent(parts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MaintenanceForecastHeader(lastUpdatedLabel: lastUpdatedLabel),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          key: const ValueKey('maintenance_forecast_card_body'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PartsMetrics.cardRadius),
            color: context.appColors.cardBackground,
            border: Border.all(color: context.appColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: ForecastSummary(parts: parts)),
                    const SizedBox(width: AppSpacing.lg),
                    ResourceBadge(percent: aggregatePercent),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxl),
                for (final part in parts) ...[
                  PartResourceRow(part: part),
                  if (part != parts.last) const SizedBox(height: AppSpacing.lg),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
