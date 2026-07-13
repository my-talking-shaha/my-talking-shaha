import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/presentation/metrics.dart';
import 'package:frontend/features/parts/presentation/utils/part_resource_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class PartResourceRow extends StatelessWidget {
  const PartResourceRow({required this.part, super.key});

  final VehiclePart part;

  @override
  Widget build(BuildContext context) {
    final progressValue = partProgressValue(part);
    final statusColor = partStatusColor(context.appColors, part.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  part.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                partResourceText(AppLocalizations.of(context), part),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (progressValue != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(PartsMetrics.progressHeight),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: PartsMetrics.progressHeight,
                backgroundColor: context.appColors.progressTrack,
                color: statusColor,
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(PartsMetrics.progressHeight),
              child: SizedBox(
                height: PartsMetrics.progressHeight,
                child: ColoredBox(color: context.appColors.unknown),
              ),
            ),
        ],
      ),
    );
  }
}
