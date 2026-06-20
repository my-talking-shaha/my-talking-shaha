import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/presentation/widgets/part_resource_row.dart';
import 'package:frontend/features/parts/presentation/widgets/parts_design_tokens.dart';
import 'package:frontend/features/parts/presentation/widgets/resource_badge.dart';

final class MaintenanceForecastCard extends StatelessWidget {
  const MaintenanceForecastCard({
    required this.parts,
    this.lastUpdatedLabel = 'UPDATED 2 HOURS AGO',
    super.key,
  });

  final List<VehiclePart> parts;
  final String lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final knownParts = parts
        .where((part) => part.remainingPercent != null)
        .toList(growable: false);
    final aggregatePercent = knownParts.isEmpty
        ? null
        : _averagePercent(knownParts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'MAINTENANCE FORECAST',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PartsDesignColors.headerText,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  lastUpdatedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PartsDesignColors.headerTextMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PartsDesignMetrics.cardRadius),
            color: PartsDesignColors.cardBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _ForecastSummary(parts: parts)),
                    const SizedBox(width: AppSpacing.lg),
                    ResourceBadge(percent: aggregatePercent),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                for (final part in parts) ...[
                  PartResourceRow(part: part),
                  if (part != parts.last) const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _ForecastSummary extends StatelessWidget {
  const _ForecastSummary({required this.parts});

  static const double _averageDailyMileageKm = 53;

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

    final headline = nextPositiveRemainingKm != null
        ? 'In ${_formatInt(nextPositiveRemainingKm)} km'
        : hasCritical
        ? 'Service needed now'
        : 'Not enough data';
    final caption = nextPositiveRemainingKm != null
        ? _approximateWindow(nextPositiveRemainingKm)
        : hasCritical
        ? 'Immediate replacement is required'
        : 'Add lifetime data to forecast';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/parts/maintenance.svg',
              width: 15,
              height: 15,
              colorFilter: const ColorFilter.mode(
                PartsDesignColors.warning,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                'NEXT SERVICE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PartsDesignColors.bodyText,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          headline,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: PartsDesignColors.bodyText,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            height: 1.18,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: PartsDesignColors.bodyTextMuted,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  String _approximateWindow(int remainingKm) {
    final days = (remainingKm / _averageDailyMileageKm).ceil();
    final displayDays = days < 1 ? 1 : days;

    return 'Approx. date: in $displayDays days';
  }
}

int _averagePercent(List<VehiclePart> knownParts) {
  final total = knownParts.fold<int>(
    0,
    (sum, part) => sum + part.remainingPercent!.clamp(0, 100).toInt(),
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
