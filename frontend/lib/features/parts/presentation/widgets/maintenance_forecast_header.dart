import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/presentation/colors.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class MaintenanceForecastHeader extends StatelessWidget {
  const MaintenanceForecastHeader({this.lastUpdatedLabel, super.key});

  final String? lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.maintenanceForecastCaps,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PartsColors.headerText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              lastUpdatedLabel ?? l10n.updatedTwoHoursAgo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PartsColors.headerTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
