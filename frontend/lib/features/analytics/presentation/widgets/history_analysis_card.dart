import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/presentation/common/analytics_common_widgets.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_formatters.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_labels.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class HistoryAnalysisCard extends StatelessWidget {
  const HistoryAnalysisCard({required this.summary, super.key});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final history = summary.history;

    return AnalyticsDashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _historyCompositionTitle(context),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _HistoryCompositionGrid(summary: summary),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final useSingleColumn = constraints.maxWidth < 310;
              final itemWidth = useSingleColumn
                  ? constraints.maxWidth
                  : (constraints.maxWidth - AppSpacing.xl) / 2;

              return Wrap(
                runSpacing: AppSpacing.lg,
                spacing: AppSpacing.xl,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: history == null
                        ? AnalyticsUnavailableText(
                            message: AppLocalizations.of(
                              context,
                            ).companyMetricsUnavailable,
                          )
                        : AnalyticsCompanyMetrics(history: history),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: history == null
                        ? AnalyticsUnavailableText(
                            message: AppLocalizations.of(
                              context,
                            ).countsUnavailable,
                          )
                        : AnalyticsHistoryCounts(history: history),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

final class _HistoryCompositionGrid extends StatelessWidget {
  const _HistoryCompositionGrid({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final repairs = summary.repairs;
    final mileage = summary.mileage;
    final fuel = summary.fuel;
    final items = [
      (_historyEventsLabel(context), _eventCount(summary.history)),
      (_historyTripsLabel(context), mileage?.monthlyDeltaKm ?? 0),
      (
        _historyRepairsLabel(context),
        repairs?.mostFrequentTypes.first.count ?? 0,
      ),
      (_historyPartsLabel(context), repairs?.mostFrequentTypes.last.count ?? 0),
      (_historyFuelLabel(context), fuel?.totalLiters.round() ?? 0),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 560 ? 2 : 5;
        const spacing = AppSpacing.sm;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final (label, value) in items)
              SizedBox(
                width: itemWidth,
                child: _HistoryMetricTile(label: label, value: value),
              ),
          ],
        );
      },
    );
  }
}

final class _HistoryMetricTile extends StatelessWidget {
  const _HistoryMetricTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface.withValues(alpha: 0.55),
        border: Border.all(color: context.appColors.border),
        borderRadius: AppRadius.input,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.appColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formatAnalyticsCompactNumber(value.toDouble()),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.appColors.primaryLight,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

int _eventCount(HistoryAnalytics? history) {
  final metrics = history?.companyMetrics;
  if (metrics == null || metrics.isEmpty) return 0;
  return metrics.first.value;
}

bool _analyticsIsRussian(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'ru';
}

String _historyCompositionTitle(BuildContext context) {
  return _analyticsIsRussian(context)
      ? 'СОСТАВ ИСТОРИИ'
      : 'HISTORY COMPOSITION';
}

String _historyEventsLabel(BuildContext context) {
  return _analyticsIsRussian(context) ? 'СОБЫТИЯ' : 'EVENTS';
}

String _historyTripsLabel(BuildContext context) {
  return _analyticsIsRussian(context) ? 'КМ ПОЕЗДОК' : 'TRIP KM';
}

String _historyRepairsLabel(BuildContext context) {
  return _analyticsIsRussian(context) ? 'РЕМОНТЫ' : 'REPAIRS';
}

String _historyPartsLabel(BuildContext context) {
  return _analyticsIsRussian(context) ? 'ДЕТАЛИ' : 'PARTS';
}

String _historyFuelLabel(BuildContext context) {
  return _analyticsIsRussian(context) ? 'ТОПЛИВО, Л' : 'FUEL, L';
}

final class AnalyticsCompanyMetrics extends StatelessWidget {
  const AnalyticsCompanyMetrics({required this.history, super.key});

  final HistoryAnalytics history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).companyMetrics,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.appColors.textSecondary,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final metric in history.companyMetrics) ...[
          AnalyticsMetricBullet(
            label: analyticsCompanyMetricLabel(
              AppLocalizations.of(context),
              metric.label,
            ),
            value: '${metric.value}/${metric.maxValue}',
          ),
          if (metric != history.companyMetrics.last)
            const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

final class AnalyticsHistoryCounts extends StatelessWidget {
  const AnalyticsHistoryCounts({required this.history, super.key});

  final HistoryAnalytics history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).keyCounts,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.appColors.textSecondary,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnalyticsMetricBullet(
          label: AppLocalizations.of(context).subscription,
          value: '${history.subscriptionCount}',
        ),
        const SizedBox(height: AppSpacing.xs),
        AnalyticsMetricBullet(
          label: AppLocalizations.of(context).electronics,
          value: '${history.electronicsCount}',
        ),
      ],
    );
  }
}
