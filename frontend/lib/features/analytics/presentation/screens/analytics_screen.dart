import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/domain/entities/mileage_trend.dart';
import 'package:frontend/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:frontend/features/parts/presentation/providers/parts_providers.dart';
import 'package:frontend/features/parts/presentation/widgets/maintenance_forecast_card.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

final class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({
    required this.vehicleId,
    this.launchedFromChat = false,
    super.key,
  });

  final String vehicleId;
  final bool launchedFromChat;

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

final class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  static const _pollingInterval = Duration(seconds: 60);

  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.year;
  AnalyticsDateRange? _selectedDateRange;
  int _selectedMileageYear = DateTime.now().year;
  int? _selectedMileageMonth;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      if (!mounted) {
        return;
      }

      ref.invalidate(
        analyticsSummaryProvider((
          vehicleId: widget.vehicleId,
          period: _selectedPeriod,
          dateRange: _selectedDateRange,
        )),
      );
      ref.invalidate(
        mileageTrendProvider((
          vehicleId: widget.vehicleId,
          filter: MileageTrendFilter(
            year: _selectedMileageYear,
            month: _selectedMileageMonth,
          ),
        )),
      );
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = (
      vehicleId: widget.vehicleId,
      period: _selectedPeriod,
      dateRange: _selectedDateRange,
    );
    final l10n = AppLocalizations.of(context);
    final summaryState = ref.watch(analyticsSummaryProvider(request));
    final mileageTrendRequest = (
      vehicleId: widget.vehicleId,
      filter: MileageTrendFilter(
        year: _selectedMileageYear,
        month: _selectedMileageMonth,
      ),
    );
    final mileageTrendState = ref.watch(
      mileageTrendProvider(mileageTrendRequest),
    );

    return Scaffold(
      appBar: widget.launchedFromChat
          ? AppBar(
              leading: IconButton(
                onPressed: () =>
                    context.go('/vehicle/${widget.vehicleId}/chat'),
                tooltip: 'Back to chat',
                icon: const Icon(Icons.chevron_left_rounded, size: 32),
              ),
              title: Text(l10n.analytics),
            )
          : null,
      body: SafeArea(
        child: summaryState.when(
          data: (summary) {
            if (!summary.hasEnoughData) {
              return _AnalyticsEmptyState(
                summary: summary,
                vehicleId: widget.vehicleId,
              );
            }

            return _AnalyticsDashboard(
              summary: summary,
              vehicleId: widget.vehicleId,
              selectedPeriod: _selectedPeriod,
              selectedDateRange: _selectedDateRange,
              mileageTrendState: mileageTrendState,
              selectedMileageYear: _selectedMileageYear,
              selectedMileageMonth: _selectedMileageMonth,
              onPeriodSelected: (period) {
                setState(() {
                  _selectedPeriod = period;
                  _selectedDateRange = null;
                });
              },
              onDateRangeSelected: _selectDateRange,
              onDateRangeCleared: () {
                setState(() => _selectedDateRange = null);
              },
              onMileageYearSelected: (year) {
                setState(() => _selectedMileageYear = year);
              },
              onMileageMonthSelected: (month) {
                setState(() => _selectedMileageMonth = month);
              },
            );
          },
          loading: () => const _AnalyticsLoadingState(),
          error: (error, stackTrace) => _AnalyticsErrorState(
            onRetry: () {
              ref.invalidate(analyticsSummaryProvider(request));
              ref.invalidate(mileageTrendProvider(mileageTrendRequest));
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final initialRange = _selectedDateRange;
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start:
            initialRange?.startDate ?? now.subtract(const Duration(days: 30)),
        end: initialRange?.endDate ?? now,
      ),
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (pickedRange == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDateRange = AnalyticsDateRange(
        startDate: pickedRange.start,
        endDate: pickedRange.end,
      );
    });
  }
}

final class _AnalyticsDashboard extends StatelessWidget {
  const _AnalyticsDashboard({
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
            color: AppColors.primaryLight,
            fontSize: 28,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 42),
        Text(l10n.analytics, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.performanceOverview,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        _PeriodSelector(
          selectedPeriod: selectedPeriod,
          onSelected: onPeriodSelected,
        ),
        const SizedBox(height: AppSpacing.md),
        _DateRangeSelector(
          selectedDateRange: selectedDateRange,
          onSelect: onDateRangeSelected,
          onClear: onDateRangeCleared,
        ),
        const SizedBox(height: AppSpacing.xl),
        _AnalyticsSummaryCard(summary: summary),
        const SizedBox(height: AppSpacing.xxl),
        _SectionHeader(
          title: l10n.seasonalExpenses,
          trailing: l10n.totalAmount(
            _formatMoney(summary.totalExpenses!.amount),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ChartCard(
          points: charts.expensesByMonth,
          valueFormatter: (value) => _formatMoney(value.round()),
          legend: l10n.monthlyExpenseTrend,
          accentColor: AppColors.primaryLight,
          chartType: _ChartType.line,
          trendPercent: summary.trendPercent,
          labelFormatter: (label) => _localizedChartLabel(l10n, label),
          axisValueFormatter: _formatCompactMoney,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _SectionHeader(title: l10n.mileageTrend),
        const SizedBox(height: AppSpacing.md),
        _MileageTrendCard(
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
        _SectionHeader(title: l10n.historyAnalysis),
        const SizedBox(height: AppSpacing.md),
        _HistoryAnalysisCard(summary: summary),
      ],
    );
  }
}

final class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onSelected,
  });

  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final period in AnalyticsPeriod.values) ...[
          Expanded(
            child: Semantics(
              selected: selectedPeriod == period,
              child: TextButton(
                key: ValueKey('analytics-period-${period.queryValue}'),
                onPressed: () => onSelected(period),
                style: TextButton.styleFrom(
                  foregroundColor: selectedPeriod == period
                      ? AppColors.background
                      : AppColors.textSecondary,
                  backgroundColor: selectedPeriod == period
                      ? AppColors.primaryLight
                      : AppColors.surfaceHigh,
                  overlayColor: Colors.transparent,
                  side: BorderSide(
                    color: selectedPeriod == period
                        ? AppColors.primaryLight
                        : AppColors.border,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.input,
                  ),
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                child: Text(_periodLabel(AppLocalizations.of(context), period)),
              ),
            ),
          ),
          if (period != AnalyticsPeriod.values.last)
            const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

final class _DateRangeSelector extends StatelessWidget {
  const _DateRangeSelector({
    required this.selectedDateRange,
    required this.onSelect,
    required this.onClear,
  });

  final AnalyticsDateRange? selectedDateRange;
  final VoidCallback onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateRange = selectedDateRange;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            key: const ValueKey('analytics-custom-date-range'),
            onPressed: onSelect,
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: Text(
              dateRange == null ? l10n.customRange : _dateRangeLabel(dateRange),
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: dateRange == null
                  ? AppColors.textSecondary
                  : AppColors.primaryLight,
              side: BorderSide(
                color: dateRange == null
                    ? AppColors.border
                    : AppColors.primaryLight,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.input,
              ),
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              textStyle: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        if (dateRange != null) ...[
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            key: const ValueKey('analytics-clear-date-range'),
            tooltip: l10n.clearCustomRange,
            onPressed: onClear,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              backgroundColor: AppColors.surfaceHigh,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.input,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

final class _AnalyticsSummaryCard extends StatelessWidget {
  const _AnalyticsSummaryCard({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalExpenses = summary.totalExpenses!;
    final mileage = summary.mileage!;

    return _DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.expensesLabel(_periodAdjective(l10n, summary.period)),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatMoney(totalExpenses.amount),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primaryLight,
                fontSize: 46,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _ExpenseCategoryGrid(categories: summary.expensesByCategory),
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
                        color: AppColors.success,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_formatDecimal(mileage.costPerKm)} ₽',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ),
              if (summary.trendPercent case final trend?)
                _TrendBadge(percent: trend),
            ],
          ),
        ],
      ),
    );
  }
}

final class _ExpenseCategoryGrid extends StatelessWidget {
  const _ExpenseCategoryGrid({required this.categories});

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
                      _categoryLabel(
                        AppLocalizations.of(context),
                        category.category,
                      ).toUpperCase(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(letterSpacing: 0.7),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatMoney(category.amount),
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

final class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up, color: AppColors.success, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${_formatDecimal(percent)}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

final class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.points,
    required this.valueFormatter,
    required this.legend,
    required this.accentColor,
    this.chartType = _ChartType.bar,
    this.trendPercent,
    this.labelFormatter,
    this.axisValueFormatter,
  });

  final List<AnalyticsChartPoint> points;
  final String Function(double value) valueFormatter;
  final String legend;
  final Color accentColor;
  final _ChartType chartType;
  final double? trendPercent;
  final String Function(String label)? labelFormatter;
  final String Function(double value)? axisValueFormatter;

  @override
  Widget build(BuildContext context) {
    final average = _averageValue(points);

    return _DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _AnalyticsChartPainter(
                points: points,
                accentColor: accentColor,
                type: chartType,
                labelFormatter: labelFormatter,
                valueFormatter: axisValueFormatter ?? valueFormatter,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  legend,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Text(
                AppLocalizations.of(
                  context,
                ).averageLabel(valueFormatter(average)),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryLight,
                ),
              ),
              if (trendPercent case final trend?) ...[
                const SizedBox(width: AppSpacing.sm),
                _TrendBadge(percent: trend),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

final class _MileageTrendCard extends StatelessWidget {
  const _MileageTrendCard({
    required this.trendState,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onYearSelected,
    required this.onMonthSelected,
  });

  final AsyncValue<MileageTrend> trendState;
  final int selectedYear;
  final int? selectedMonth;
  final ValueChanged<int> onYearSelected;
  final ValueChanged<int?> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final children = [
                _MileageFilterDropdown<int>(
                  key: const ValueKey('analytics-mileage-year-filter'),
                  value: selectedYear,
                  items: [
                    for (final year in _mileageYearOptions())
                      DropdownMenuItem(value: year, child: Text('$year')),
                  ],
                  onChanged: (year) {
                    if (year != null) {
                      onYearSelected(year);
                    }
                  },
                ),
                _MileageFilterDropdown<int>(
                  key: const ValueKey('analytics-mileage-month-filter'),
                  value: selectedMonth ?? 0,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(l10n.allMonths)),
                    for (var month = 1; month <= 12; month++)
                      DropdownMenuItem(
                        value: month,
                        child: Text(_monthName(l10n, month)),
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
                return _UnavailableText(
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
                      painter: _AnalyticsChartPainter(
                        points: chartPoints,
                        accentColor: AppColors.success,
                        type: _ChartType.line,
                        labelFormatter: (label) =>
                            _localizedChartLabel(l10n, label),
                        valueFormatter: _formatCompactKilometers,
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
                          color: AppColors.success,
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
                        '${_formatNumber(trend.points.last.mileageKm)} km',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.primaryLight),
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
            error: (error, stackTrace) =>
                _UnavailableText(message: l10n.couldNotLoadMileageTrend),
          ),
        ],
      ),
    );
  }
}

final class _MileageFilterDropdown<T> extends StatelessWidget {
  const _MileageFilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: AppColors.surfaceHigh,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.primaryLight),
        ),
      ),
      style: Theme.of(context).textTheme.labelMedium,
      iconEnabledColor: AppColors.textSecondary,
    );
  }
}

final class _HistoryAnalysisCard extends StatelessWidget {
  const _HistoryAnalysisCard({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final charts = summary.charts!;
    final history = summary.history;

    return _DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).performanceTrendOverTime,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 128,
            width: double.infinity,
            child: CustomPaint(
              painter: _AnalyticsChartPainter(
                points: charts.mileageByMonth,
                accentColor: AppColors.success,
                type: _ChartType.bar,
                showLabels: false,
                valueFormatter: _formatCompactKilometers,
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
                        ? _UnavailableText(
                            message: AppLocalizations.of(
                              context,
                            ).companyMetricsUnavailable,
                          )
                        : _CompanyMetrics(history: history),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: history == null
                        ? _UnavailableText(
                            message: AppLocalizations.of(
                              context,
                            ).countsUnavailable,
                          )
                        : _HistoryCounts(history: history),
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

final class _CompanyMetrics extends StatelessWidget {
  const _CompanyMetrics({required this.history});

  final HistoryAnalytics history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).companyMetrics,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final metric in history.companyMetrics) ...[
          _MetricBullet(
            label: _companyMetricLabel(
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

String _companyMetricLabel(AppLocalizations l10n, String label) {
  return switch (label.trim().toLowerCase()) {
    'events' => l10n.eventsMetric,
    'trip km' || 'trip kilometers' => l10n.tripKmMetric,
    'reliability' => l10n.reliabilityMetric,
    'efficiency' => l10n.efficiencyMetric,
    'maintenance load' => l10n.maintenanceLoadMetric,
    _ => label,
  };
}

final class _HistoryCounts extends StatelessWidget {
  const _HistoryCounts({required this.history});

  final HistoryAnalytics history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).keyCounts,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MetricBullet(
          label: AppLocalizations.of(context).subscription,
          value: '${history.subscriptionCount}',
        ),
        const SizedBox(height: AppSpacing.xs),
        _MetricBullet(
          label: AppLocalizations.of(context).electronics,
          value: '${history.electronicsCount}',
        ),
      ],
    );
  }
}

final class _UnavailableText extends StatelessWidget {
  const _UnavailableText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
    );
  }
}

final class _MetricBullet extends StatelessWidget {
  const _MetricBullet({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

final class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.primaryLight),
          ),
      ],
    );
  }
}

final class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceHigh,
            AppColors.surface,
            AppColors.backgroundDark,
          ],
        ),
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.card,
      ),
      child: child,
    );
  }
}

final class _AnalyticsEmptyState extends StatelessWidget {
  const _AnalyticsEmptyState({required this.summary, required this.vehicleId});

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
            const Icon(
              Icons.analytics_outlined,
              color: AppColors.primaryLight,
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
                _SuggestionChip(
                  label: l10n.addTrip,
                  onPressed: () => _openHistoryAdd(context, type: 'trip'),
                ),
                _SuggestionChip(
                  label: l10n.addRefuel,
                  onPressed: () => _openHistoryAdd(context),
                ),
                _SuggestionChip(
                  label: l10n.addRepair,
                  onPressed: () =>
                      _openHistoryAdd(context, type: 'maintenance'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openHistoryAdd(BuildContext context, {String? type}) {
    final route = Uri(
      path: '/vehicle/$vehicleId/history/add',
      queryParameters: type == null ? null : {'type': type},
    ).toString();
    unawaited(context.push(route));
  }
}

final class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onPressed,
      label: Text(label),
      backgroundColor: AppColors.surfaceHigh,
      side: const BorderSide(color: AppColors.border),
      labelStyle: Theme.of(context).textTheme.labelMedium,
      shape: const StadiumBorder(),
    );
  }
}

final class _AnalyticsLoadingState extends StatelessWidget {
  const _AnalyticsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

final class _AnalyticsErrorState extends StatelessWidget {
  const _AnalyticsErrorState({required this.onRetry});

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

enum _ChartType { bar, line }

final class _AnalyticsChartPainter extends CustomPainter {
  const _AnalyticsChartPainter({
    required this.points,
    required this.accentColor,
    required this.type,
    this.showLabels = true,
    this.labelFormatter,
    this.valueFormatter = _formatCompactNumber,
  });

  final List<AnalyticsChartPoint> points;
  final Color accentColor;
  final _ChartType type;
  final bool showLabels;
  final String Function(String label)? labelFormatter;
  final String Function(double value) valueFormatter;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.isEmpty) {
      return;
    }

    const axisWidth = 46.0;
    const rightPadding = 4.0;
    const topPadding = 10.0;
    final bottomPadding = showLabels ? 26.0 : 4.0;
    final plotRect = Rect.fromLTRB(
      axisWidth,
      topPadding,
      size.width - rightPadding,
      size.height - bottomPadding,
    );
    if (plotRect.width <= 0 || plotRect.height <= 0) {
      return;
    }

    final maxValue = _niceAxisMax(
      points.map((point) => point.value).reduce(math.max),
    );

    _drawValueAxis(canvas, plotRect, maxValue);

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var index = 0; index <= 4; index++) {
      final y = plotRect.top + (plotRect.height * index / 4);
      canvas.drawLine(
        Offset(plotRect.left, y),
        Offset(plotRect.right, y),
        gridPaint,
      );
    }

    switch (type) {
      case _ChartType.bar:
        _drawBars(canvas, plotRect, maxValue);
      case _ChartType.line:
        _drawLine(canvas, plotRect, maxValue);
    }

    if (showLabels) {
      _drawLabels(canvas, plotRect);
    }
  }

  void _drawValueAxis(Canvas canvas, Rect plotRect, double maxValue) {
    for (var index = 0; index <= 4; index++) {
      final value = maxValue * (4 - index) / 4;
      final y = plotRect.top + (plotRect.height * index / 4);
      final painter = TextPainter(
        text: TextSpan(
          text: valueFormatter(value),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: plotRect.left - AppSpacing.xs);
      painter.paint(
        canvas,
        Offset(
          plotRect.left - AppSpacing.xs - painter.width,
          y - (painter.height / 2),
        ),
      );
    }
  }

  void _drawBars(Canvas canvas, Rect plotRect, double maxValue) {
    final slotWidth = plotRect.width / points.length;
    final barWidth = math.min(42.0, slotWidth * 0.62);
    final paint = Paint()..color = accentColor.withValues(alpha: 0.72);

    for (var index = 0; index < points.length; index++) {
      final value = points[index].value;
      final barHeight = plotRect.height * (value / maxValue);
      final left =
          plotRect.left + (slotWidth * index) + ((slotWidth - barWidth) / 2);
      final top = plotRect.bottom - barHeight;
      final rect = Rect.fromLTWH(left, top, barWidth, barHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        paint,
      );
    }
  }

  void _drawLine(Canvas canvas, Rect plotRect, double maxValue) {
    final path = Path();
    final fillPath = Path();
    final step = points.length == 1
        ? 0.0
        : plotRect.width / (points.length - 1);

    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1
          ? plotRect.left + (plotRect.width / 2)
          : plotRect.left + (step * index);
      final y =
          plotRect.bottom - (plotRect.height * points[index].value / maxValue);
      final offset = Offset(x, y);

      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
        fillPath
          ..moveTo(offset.dx, plotRect.bottom)
          ..lineTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
        fillPath.lineTo(offset.dx, offset.dy);
      }

      canvas.drawCircle(offset, 4, Paint()..color = accentColor);
    }

    fillPath
      ..lineTo(plotRect.right, plotRect.bottom)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = accentColor.withValues(alpha: 0.10),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = accentColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawLabels(Canvas canvas, Rect plotRect) {
    final slotWidth = plotRect.width / points.length;

    for (var index = 0; index < points.length; index++) {
      final painter = TextPainter(
        text: TextSpan(
          text:
              (labelFormatter?.call(points[index].label) ?? points[index].label)
                  .toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: slotWidth);
      final x =
          plotRect.left +
          (slotWidth * index) +
          ((slotWidth - painter.width) / 2);
      painter.paint(canvas, Offset(x, plotRect.bottom + AppSpacing.sm));
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsChartPainter oldDelegate) {
    return points != oldDelegate.points ||
        accentColor != oldDelegate.accentColor ||
        type != oldDelegate.type ||
        showLabels != oldDelegate.showLabels ||
        labelFormatter != oldDelegate.labelFormatter ||
        valueFormatter != oldDelegate.valueFormatter;
  }
}

String _periodLabel(AppLocalizations l10n, AnalyticsPeriod period) {
  return switch (period) {
    AnalyticsPeriod.month => l10n.month,
    AnalyticsPeriod.year => l10n.yearPeriod,
    AnalyticsPeriod.all => l10n.allTime,
  };
}

String _periodAdjective(AppLocalizations l10n, AnalyticsPeriod period) {
  return switch (period) {
    AnalyticsPeriod.month => l10n.monthly,
    AnalyticsPeriod.year => l10n.annual,
    AnalyticsPeriod.all => l10n.allTimeAdjective,
  };
}

String _monthName(AppLocalizations l10n, int month) {
  return switch (month) {
    1 => l10n.january,
    2 => l10n.february,
    3 => l10n.march,
    4 => l10n.april,
    5 => l10n.may,
    6 => l10n.june,
    7 => l10n.july,
    8 => l10n.august,
    9 => l10n.september,
    10 => l10n.october,
    11 => l10n.november,
    12 => l10n.december,
    _ => month.toString(),
  };
}

String _shortMonthName(AppLocalizations l10n, int month) {
  final name = _monthName(l10n, month);
  return name.length <= 3 ? name : name.substring(0, 3);
}

String _localizedChartLabel(AppLocalizations l10n, String label) {
  final normalized = label.trim().toLowerCase();
  final parts = normalized.split(RegExp(r'\s+'));
  final leadingMonth = _monthNumber(parts.first);
  if (leadingMonth != null) {
    final monthLabel = _shortMonthName(l10n, leadingMonth);
    return parts.length > 1
        ? '$monthLabel ${parts.sublist(1).join(' ')}'
        : monthLabel;
  }

  final monthValue = int.tryParse(normalized);
  if (monthValue != null && monthValue >= 1 && monthValue <= 12) {
    return _shortMonthName(l10n, monthValue);
  }

  return switch (normalized) {
    'winter' => l10n.winter,
    'spring' => l10n.spring,
    'summer' => l10n.summer,
    'autumn' || 'fall' => l10n.autumn,
    _ => label,
  };
}

int? _monthNumber(String label) {
  return switch (label) {
    'jan' || 'january' => 1,
    'feb' || 'february' => 2,
    'mar' || 'march' => 3,
    'apr' || 'april' => 4,
    'may' => 5,
    'jun' || 'june' => 6,
    'jul' || 'july' => 7,
    'aug' || 'august' => 8,
    'sep' || 'september' => 9,
    'oct' || 'october' => 10,
    'nov' || 'november' => 11,
    'dec' || 'december' => 12,
    _ => null,
  };
}

double _niceAxisMax(double value) {
  if (value <= 0) return 1;

  final exponent = (math.log(value) / math.ln10).floor();
  final magnitude = math.pow(10, exponent).toDouble();
  final normalized = value / magnitude;
  final niceNormalized = switch (normalized) {
    <= 1 => 1,
    <= 2 => 2,
    <= 5 => 5,
    _ => 10,
  };

  return niceNormalized * magnitude;
}

String _dateRangeLabel(AnalyticsDateRange dateRange) {
  return '${_dateLabel(dateRange.startDate)} - ${_dateLabel(dateRange.endDate)}';
}

String _dateLabel(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

List<int> _mileageYearOptions() {
  final currentYear = DateTime.now().year;
  return [for (var year = currentYear; year >= currentYear - 4; year--) year];
}

String _categoryLabel(AppLocalizations l10n, ExpenseCategory category) {
  return switch (category) {
    ExpenseCategory.fuel => l10n.fuelCategory,
    ExpenseCategory.maintenance => l10n.maintenanceCategory,
    ExpenseCategory.parts => l10n.partsCategory,
    ExpenseCategory.other => l10n.otherCategory,
  };
}

String _formatMoney(int amount) {
  return '${_formatNumber(amount)} ₽';
}

String _formatCompactMoney(double value) {
  return '${_formatCompactNumber(value)} ₽';
}

String _formatCompactKilometers(double value) {
  return '${_formatCompactNumber(value)} km';
}

String _formatCompactNumber(double value) {
  final absValue = value.abs();
  if (absValue >= 1000000) {
    return '${_formatCompactDecimal(value / 1000000)}M';
  }
  if (absValue >= 1000) {
    return '${_formatCompactDecimal(value / 1000)}K';
  }
  return _formatNumber(value);
}

String _formatCompactDecimal(double value) {
  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return rounded.round().toString();
  }
  return rounded.toStringAsFixed(1);
}

String _formatNumber(num value) {
  final roundedValue = value.round();
  final digits = roundedValue.abs().toString();
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }

  return roundedValue < 0 ? '-$buffer' : buffer.toString();
}

String _formatDecimal(double value) {
  final fixed = value.toStringAsFixed(1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}

double _averageValue(List<AnalyticsChartPoint> points) {
  if (points.isEmpty) {
    return 0;
  }

  final total = points.fold<double>(0, (sum, point) => sum + point.value);
  return total / points.length;
}
