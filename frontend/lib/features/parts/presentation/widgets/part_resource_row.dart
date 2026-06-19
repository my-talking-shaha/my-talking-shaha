import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';

final class PartResourceRow extends StatelessWidget {
  const PartResourceRow({required this.part, super.key});

  final VehiclePart part;

  @override
  Widget build(BuildContext context) {
    final remainingPercent = part.remainingPercent;
    final progressValue = remainingPercent == null
        ? null
        : (remainingPercent / 100).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                _resourceText(part),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _statusColor(part.status),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (progressValue != null) ...[
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              backgroundColor: AppColors.surfaceHighest,
              color: _statusColor(part.status),
            ),
          ],
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

  return '$remainingPercent% · ${_formatInt(remainingKm)} km';
}

Color _statusColor(PartResourceStatus status) {
  return switch (status) {
    PartResourceStatus.ok => AppColors.success,
    PartResourceStatus.warning => AppColors.warning,
    PartResourceStatus.critical => AppColors.error,
    PartResourceStatus.unknown => AppColors.textMuted,
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
