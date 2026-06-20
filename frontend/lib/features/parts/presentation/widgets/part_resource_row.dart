import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/presentation/widgets/parts_design_tokens.dart';

final class PartResourceRow extends StatelessWidget {
  const PartResourceRow({required this.part, super.key});

  final VehiclePart part;

  @override
  Widget build(BuildContext context) {
    final remainingPercent = part.remainingPercent;
    final progressValue = remainingPercent == null
        ? null
        : (remainingPercent / 100).clamp(0.0, 1.0).toDouble();
    final statusColor = _statusColor(part.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        part.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: statusColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Text(
                  _resourceText(part),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (progressValue != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(
                PartsDesignMetrics.progressHeight,
              ),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: PartsDesignMetrics.progressHeight,
                backgroundColor: PartsDesignColors.progressTrack,
                color: statusColor,
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(
                PartsDesignMetrics.progressHeight,
              ),
              child: const SizedBox(
                height: PartsDesignMetrics.progressHeight,
                child: ColoredBox(color: PartsDesignColors.unknown),
              ),
            ),
        ],
      ),
    );
  }
}

String _resourceText(VehiclePart part) {
  final remainingKm = part.remainingKm;
  final remainingPercent = part.remainingPercent;

  if (remainingKm == null || remainingPercent == null) {
    return 'Lifetime not set';
  }

  final displayPercent = remainingPercent.clamp(0, 100);
  final displayRemainingKm = remainingKm < 0 ? 0 : remainingKm;

  return '$displayPercent% · ${_formatInt(displayRemainingKm)} km';
}

Color _statusColor(PartResourceStatus status) {
  return switch (status) {
    PartResourceStatus.ok => PartsDesignColors.ok,
    PartResourceStatus.warning => PartsDesignColors.warning,
    PartResourceStatus.critical => PartsDesignColors.critical,
    PartResourceStatus.unknown => PartsDesignColors.unknown,
  };
}

String _formatInt(int value) {
  final prefix = value < 0 ? '-' : '';
  final formatted = value.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );

  return '$prefix$formatted';
}
