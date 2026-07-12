import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/domain/entities/mileage_trend.dart';
import 'package:frontend/features/analytics/presentation/colors.dart';
import 'package:frontend/features/analytics/presentation/common/analytics_common_widgets.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_formatters.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_interactions.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_labels.dart';
import 'package:frontend/features/analytics/presentation/widgets/analytics_chart.dart';
import 'package:frontend/features/analytics/presentation/widgets/analytics_filters.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class MileageTrendCard extends StatelessWidget {
  const MileageTrendCard({
    required this.trendState,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onYearSelected,
    required this.onMonthSelected,
    super.key,
  });

  final AsyncValue<MileageTrend> trendState;
  final int selectedYear;
  final int? selectedMonth;
  final ValueChanged<int> onYearSelected;
  final ValueChanged<int?> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnalyticsDashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final children = [
                AnalyticsMileageFilterDropdown<int>(
                  key: const ValueKey('analytics-mileage-year-filter'),
                  value: selectedYear,
                  items: [
                    for (final year in analyticsMileageYearOptions())
                      DropdownMenuItem(value: year, child: Text('$year')),
                  ],
                  onChanged: (year) {
                    if (year != null) {
                      onYearSelected(year);
                    }
                  },
                ),
                AnalyticsMileageFilterDropdown<int>(
                  key: const ValueKey('analytics-mileage-month-filter'),
                  value: selectedMonth ?? 0,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(l10n.allMonths)),
                    for (var month = 1; month <= 12; month++)
                      DropdownMenuItem(
                        value: month,
                        child: Text(analyticsMonthName(l10n, month)),
                      ),
                  ],
                  onChanged: (month) {
                    onMonthSelected(month == null || month == 0 ? null : month);
                  },
                ),
              ];

              if (compact) {
                return Column(
                  children: [
                    for (var index = 0; index < children.length; index++) ...[
                      children[index],
                      if (index != children.length - 1)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: children.first),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: children.last),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          trendState.when(
            data: (trend) {
              if (!trend.hasData || trend.points.isEmpty) {
                return AnalyticsUnavailableText(
                  message: l10n.mileageDataUnavailableForFilter,
                );
              }

              final chartPoints = [
                for (final point in trend.points)
                  AnalyticsChartPoint(
                    label: point.label,
                    value: point.mileageKm.toDouble(),
                  ),
              ];

              return Column(
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: AnalyticsChartPainter(
                        points: chartPoints,
                        accentColor: AnalyticsColors.success,
                        type: AnalyticsChartType.line,
                        labelFormatter: (label) =>
                            analyticsLocalizedChartLabel(l10n, label),
                        valueFormatter: formatAnalyticsCompactKilometers,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AnalyticsColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          selectedMonth == null
                              ? l10n.accumulatedMileageByMonth
                              : l10n.accumulatedMileageByDay,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      Text(
                        '${formatAnalyticsNumber(trend.points.last.mileageKm)} km',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AnalyticsColors.primaryLight),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => AnalyticsUnavailableText(
              message: l10n.couldNotLoadMileageTrend,
            ),
          ),
        ],
      ),
    );
  }
}
