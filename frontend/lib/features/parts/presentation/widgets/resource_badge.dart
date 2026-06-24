import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/presentation/widgets/parts_design_tokens.dart';

final class ResourceBadge extends StatelessWidget {
  const ResourceBadge({required this.percent, super.key});

  final int? percent;

  @override
  Widget build(BuildContext context) {
    final percent = this.percent;

    return Container(
      width: 92,
      height: 86,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: PartsDesignColors.badgeBackground,
        borderRadius: BorderRadius.circular(PartsDesignMetrics.cardRadius),
        border: Border.all(color: PartsDesignColors.badgeBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            percent == null ? '--' : '$percent%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: PartsDesignColors.warning,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'RESOURCE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PartsDesignColors.warning,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
