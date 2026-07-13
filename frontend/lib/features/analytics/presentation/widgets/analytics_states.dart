import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_interactions.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class AnalyticsEmptyState extends StatelessWidget {
  const AnalyticsEmptyState({
    required this.summary,
    required this.vehicleId,
    super.key,
  });

  final AnalyticsSummary summary;
  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              color: context.appColors.primaryLight,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.notEnoughAnalytics,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.analyticsEmptyDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AnalyticsSuggestionChip(
                  label: l10n.addTrip,
                  onPressed: () => openAnalyticsHistoryAdd(
                    context,
                    vehicleId: vehicleId,
                    type: 'trip',
                  ),
                ),
                AnalyticsSuggestionChip(
                  label: l10n.addRefuel,
                  onPressed: () =>
                      openAnalyticsHistoryAdd(context, vehicleId: vehicleId),
                ),
                AnalyticsSuggestionChip(
                  label: l10n.addRepair,
                  onPressed: () => openAnalyticsHistoryAdd(
                    context,
                    vehicleId: vehicleId,
                    type: 'maintenance',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class AnalyticsSuggestionChip extends StatelessWidget {
  const AnalyticsSuggestionChip({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onPressed,
      label: Text(label),
      backgroundColor: context.appColors.surfaceHigh,
      side: BorderSide(color: context.appColors.border),
      labelStyle: Theme.of(context).textTheme.labelMedium,
      shape: const StadiumBorder(),
    );
  }
}

final class AnalyticsLoadingState extends StatelessWidget {
  const AnalyticsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

final class AnalyticsErrorState extends StatelessWidget {
  const AnalyticsErrorState({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.couldNotLoadAnalytics,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
