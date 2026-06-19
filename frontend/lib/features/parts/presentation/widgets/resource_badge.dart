import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class ResourceBadge extends StatelessWidget {
  const ResourceBadge({required this.percent, super.key});

  final int? percent;

  @override
  Widget build(BuildContext context) {
    final percent = this.percent;

    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.42)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            percent == null ? '--' : '$percent%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'RESOURCE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
