import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/presentation/common/analytics_common_widgets.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_formatters.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_labels.dart';
import 'package:frontend/features/analytics/presentation/widgets/analytics_chart.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class HistoryAnalysisCard extends StatelessWidget {
  const HistoryAnalysisCard({required this.summary, super.key});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final charts = summary.charts!;
    final history = summary.history;

    return AnalyticsDashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).performanceTrendOverTime,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 128,
            width: double.infinity,
            child: CustomPaint(
              painter: AnalyticsChartPainter(
                borderColor: context.appColors.border,
                labelColor: context.appColors.textSecondary,
                points: charts.mileageByMonth,
                accentColor: context.appColors.success,
                type: AnalyticsChartType.bar,
                showLabels: false,
                valueFormatter: formatAnalyticsCompactKilometers,
              ),
            ),
          ),
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
