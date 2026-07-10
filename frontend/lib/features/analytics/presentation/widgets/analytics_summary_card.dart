import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/presentation/colors.dart';
import 'package:frontend/features/analytics/presentation/common/analytics_common_widgets.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_formatters.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_labels.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class AnalyticsSummaryCard extends StatelessWidget {
  const AnalyticsSummaryCard({required this.summary, super.key});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalExpenses = summary.totalExpenses!;
    final mileage = summary.mileage!;

    return AnalyticsDashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.expensesLabel(analyticsPeriodAdjective(l10n, summary.period)),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AnalyticsColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatAnalyticsMoney(totalExpenses.amount),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AnalyticsColors.primaryLight,
                fontSize: 46,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AnalyticsExpenseCategoryGrid(categories: summary.expensesByCategory),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.costPerKm,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AnalyticsColors.success,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${formatAnalyticsDecimal(mileage.costPerKm)} ₽',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AnalyticsColors.success),
                    ),
                  ],
                ),
              ),
              if (summary.trendPercent case final trend?)
                AnalyticsTrendBadge(percent: trend),
            ],
          ),
        ],
      ),
    );
  }
}

final class AnalyticsExpenseCategoryGrid extends StatelessWidget {
  const AnalyticsExpenseCategoryGrid({required this.categories, super.key});

  final List<ExpenseCategoryAmount> categories;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 300;
        final itemWidth = useSingleColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - AppSpacing.lg) / 2;

        return Wrap(
          runSpacing: AppSpacing.lg,
          spacing: AppSpacing.lg,
          children: [
            for (final category in categories)
              SizedBox(
                width: itemWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analyticsCategoryLabel(
                        AppLocalizations.of(context),
                        category.category,
                      ).toUpperCase(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(letterSpacing: 0.7),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      formatAnalyticsMoney(category.amount),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
