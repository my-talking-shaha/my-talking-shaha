import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/domain/entities/mileage_trend.dart';
import 'package:frontend/features/analytics/presentation/common/analytics_common_widgets.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_formatters.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_labels.dart';
import 'package:frontend/features/analytics/presentation/widgets/analytics_chart.dart';
import 'package:frontend/features/analytics/presentation/widgets/analytics_filters.dart';
import 'package:frontend/features/analytics/presentation/widgets/analytics_summary_card.dart';
import 'package:frontend/features/analytics/presentation/widgets/history_analysis_card.dart';
import 'package:frontend/features/analytics/presentation/widgets/mileage_trend_card.dart';
import 'package:frontend/features/parts/di/parts_providers.dart';
import 'package:frontend/features/parts/presentation/widgets/maintenance_forecast_card.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({
    required this.summary,
    required this.vehicleId,
    required this.selectedPeriod,
    required this.selectedDateRange,
    required this.mileageTrendState,
    required this.selectedMileageYear,
    required this.selectedMileageMonth,
    required this.onPeriodSelected,
    required this.onDateRangeSelected,
    required this.onDateRangeCleared,
    required this.onMileageYearSelected,
    required this.onMileageMonthSelected,
    super.key,
  });

  final AnalyticsSummary summary;
  final String vehicleId;
  final AnalyticsPeriod selectedPeriod;
  final AnalyticsDateRange? selectedDateRange;
  final AsyncValue<MileageTrend> mileageTrendState;
  final int selectedMileageYear;
  final int? selectedMileageMonth;
  final ValueChanged<AnalyticsPeriod> onPeriodSelected;
  final VoidCallback onDateRangeSelected;
  final VoidCallback onDateRangeCleared;
  final ValueChanged<int> onMileageYearSelected;
  final ValueChanged<int?> onMileageMonthSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final charts = summary.charts!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        Text(
          l10n.intelligence,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: context.appColors.primaryLight,
            fontSize: 28,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 42),
        Text(l10n.analytics, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.performanceOverview,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AnalyticsPeriodSelector(
          selectedPeriod: selectedPeriod,
          onSelected: onPeriodSelected,
        ),
        const SizedBox(height: AppSpacing.md),
        AnalyticsDateRangeSelector(
          selectedDateRange: selectedDateRange,
          onSelect: onDateRangeSelected,
          onClear: onDateRangeCleared,
        ),
        const SizedBox(height: AppSpacing.xl),
        AnalyticsSummaryCard(summary: summary),
        const SizedBox(height: AppSpacing.xxl),
        AnalyticsSectionHeader(
          title: l10n.seasonalExpenses,
          trailing: l10n.totalAmount(
            formatAnalyticsMoney(summary.totalExpenses!.amount),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnalyticsChartCard(
          points: charts.expensesByMonth,
          valueFormatter: (value) => formatAnalyticsMoney(value.round()),
          legend: l10n.monthlyExpenseTrend,
          accentColor: context.appColors.primaryLight,
          chartType: AnalyticsChartType.line,
          trendPercent: summary.trendPercent,
          labelFormatter: (label) => analyticsLocalizedChartLabel(l10n, label),
          axisValueFormatter: formatAnalyticsCompactMoney,
        ),
        const SizedBox(height: AppSpacing.xxl),
        AnalyticsSectionHeader(title: l10n.mileageTrend),
        const SizedBox(height: AppSpacing.md),
        MileageTrendCard(
          trendState: mileageTrendState,
          selectedYear: selectedMileageYear,
          selectedMonth: selectedMileageMonth,
          onYearSelected: onMileageYearSelected,
          onMonthSelected: onMileageMonthSelected,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Consumer(
          builder: (context, ref, child) => ref
              .watch(vehiclePartsProvider(vehicleId))
              .maybeWhen(
                data: (parts) => MaintenanceForecastCard(parts: parts),
                orElse: () => const SizedBox.shrink(),
              ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AnalyticsSectionHeader(title: l10n.historyAnalysis),
        const SizedBox(height: AppSpacing.md),
        HistoryAnalysisCard(summary: summary),
      ],
    );
  }
}
