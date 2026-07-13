import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/common/dashboard_card.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_actions.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_text_style_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class VinCard extends StatelessWidget {
  const VinCard({required this.vin, super.key});

  final String? vin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = vin?.trim();
    final hasVin = value != null && value.isNotEmpty;

    return DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.vinNumber,
                  style: DashboardTextStyleUtils.sectionLabel(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hasVin ? value : l10n.vinUnavailable,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.appColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: hasVin ? l10n.copyVin : l10n.vinUnavailable,
            style: IconButton.styleFrom(
              foregroundColor: context.appColors.primaryLight,
              disabledForegroundColor: context.appColors.textDisabled,
            ),
            onPressed: hasVin
                ? () => DashboardActions.copyVin(context, value)
                : null,
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
    );
  }
}
