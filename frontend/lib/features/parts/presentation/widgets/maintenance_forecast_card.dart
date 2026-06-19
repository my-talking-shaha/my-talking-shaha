import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/presentation/widgets/part_resource_row.dart';
import 'package:frontend/features/parts/presentation/widgets/resource_badge.dart';

final class MaintenanceForecastCard extends StatelessWidget {
  const MaintenanceForecastCard({required this.parts, super.key});

  final List<VehiclePart> parts;

  @override
  Widget build(BuildContext context) {
    final knownParts = parts
        .where((part) => part.remainingPercent != null)
        .toList(growable: false);
    final aggregatePercent = knownParts.isEmpty
        ? null
        : _averagePercent(knownParts);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
        color: const Color(0x0D32353C),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'MAINTENANCE FORECAST',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _ForecastSummary(parts: parts)),
                const SizedBox(width: AppSpacing.md),
                ResourceBadge(percent: aggregatePercent),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            for (final part in parts) ...[
              PartResourceRow(part: part),
              if (part != parts.last) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

final class _ForecastSummary extends StatelessWidget {
  const _ForecastSummary({required this.parts});

  final List<VehiclePart> parts;

  @override
  Widget build(BuildContext context) {
    final hasCritical = parts.any(
      (part) => part.status == PartResourceStatus.critical,
    );
    final nextPositiveRemainingKm = parts
        .map((part) => part.remainingKm)
        .whereType<int>()
        .where((remainingKm) => remainingKm > 0)
        .fold<int?>(null, (min, remainingKm) {
          if (min == null || remainingKm < min) {
            return remainingKm;
          }

          return min;
        });

    final headline = hasCritical
        ? 'Service needed now'
        : nextPositiveRemainingKm == null
        ? 'Not enough data'
        : 'In ${_formatInt(nextPositiveRemainingKm)} km';
    final caption = hasCritical
        ? 'Some parts have exhausted lifetime'
        : nextPositiveRemainingKm == null
        ? 'Add part lifetime to build a forecast'
        : 'Next scheduled replacement';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 24, height: 1.1),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

int _averagePercent(List<VehiclePart> knownParts) {
  final total = knownParts.fold<int>(
    0,
    (sum, part) => sum + part.remainingPercent!,
  );

  return (total / knownParts.length).round().clamp(0, 100);
}

String _formatInt(int value) {
  final prefix = value < 0 ? '-' : '';
  final formatted = value.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );

  return '$prefix$formatted';
}
