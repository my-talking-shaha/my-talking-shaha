import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/presentation/metrics.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class ResourceBadge extends StatelessWidget {
  const ResourceBadge({required this.percent, super.key});

  final int? percent;

  @override
  Widget build(BuildContext context) {
    final percent = this.percent;

    return Container(
      width: 126,
      height: 86,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.badgeBackground,
        borderRadius: BorderRadius.circular(PartsMetrics.cardRadius),
        border: Border.all(color: context.appColors.badgeBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            percent == null ? '--' : '$percent%',
            maxLines: 1,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: context.appColors.partsWarning,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppLocalizations.of(context).resource,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.partsWarning,
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
