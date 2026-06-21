import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/presentation/providers/analytics_providers.dart';

final class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

final class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.year;

  @override
  Widget build(BuildContext context) {
    final request = (vehicleId: widget.vehicleId, period: _selectedPeriod);
    final summaryState = ref.watch(analyticsSummaryProvider(request));

    return Scaffold(
      body: SafeArea(
        child: summaryState.when(
          data: (summary) {
            if (!summary.hasEnoughData) {
              return _AnalyticsEmptyState(summary: summary);
            }

            return _AnalyticsDashboard(
              summary: summary,
              selectedPeriod: _selectedPeriod,
              onPeriodSelected: (period) {
                setState(() => _selectedPeriod = period);
              },
            );
          },
          loading: () => const _AnalyticsLoadingState(),
          error: (error, stackTrace) => _AnalyticsErrorState(
            onRetry: () {
              ref.invalidate(analyticsSummaryProvider(request));
            },
          ),
        ),
      ),
    );
  }
}

final class _AnalyticsDashboard extends StatelessWidget {
  const _AnalyticsDashboard({
    required this.summary,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  final AnalyticsSummary summary;
  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
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
          'Intelligence',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primaryLight,
                fontSize: 28,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 42),
        Text('Analytics', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Performance and spending overview',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _PeriodSelector(
          selectedPeriod: selectedPeriod,
          onSelected: onPeriodSelected,
        ),
        const SizedBox(height: AppSpacing.xl),
        _AnalyticsSummaryCard(summary: summary),
        const SizedBox(height: AppSpacing.xxl),
        _SectionHeader(
          title: '${_periodNoun(summary.period)} EXPENSES',
          trailing:
              'AVG: ${_formatMoney(_averageValue(charts.expensesByMonth).round())}',
        ),
        const SizedBox(height: AppSpacing.md),
        _ChartCard(
          points: charts.expensesByMonth,
          valueFormatter: (value) => _formatMoney(value.round()),
          legend: 'Expenses (RUB)',
          accentColor: AppColors.primaryLight,
          chartType: _ChartType.line,
        ),
        const SizedBox(height: AppSpacing.xxl),
        // TODO(parts-rebase): Insert MaintenanceForecastCard from
        // features/parts here after the parts branch is rebased.
        // Keep forecast calculations owned by the parts feature.
        const _SectionHeader(title: 'HISTORY ANALYSIS'),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                ),
                child: Text(_periodLabel(period)),
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

final class _AnalyticsSummaryCard extends StatelessWidget {
  const _AnalyticsSummaryCard({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final totalExpenses = summary.totalExpenses!;
    final mileage = summary.mileage!;

    return _DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_periodAdjective(summary.period)} EXPENSES',
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
                      'COST PER KM',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            letterSpacing: 0.7,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_formatDecimal(mileage.costPerKm)} ₽',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
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
                      _categoryLabel(category.category).toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            letterSpacing: 0.7,
                          ),
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
          const Icon(
            Icons.trending_up,
            color: AppColors.success,
            size: 14,
          ),
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
  });

  final List<AnalyticsChartPoint> points;
  final String Function(double value) valueFormatter;
  final String legend;
  final Color accentColor;
  final _ChartType chartType;

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
                'Avg: ${valueFormatter(average)}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primaryLight,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _HistoryAnalysisCard extends StatelessWidget {
  const _HistoryAnalysisCard({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final charts = summary.charts!;
    final mileage = summary.mileage!;
    final fuel = summary.fuel!;
    final repairs = summary.repairs!;

    return _DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REPAIR FREQUENCY OVER TIME',
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
                points: charts.repairsByMonth,
                accentColor: AppColors.success,
                type: _ChartType.bar,
                showLabels: false,
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
                    child: _FrequentRepairs(repairs: repairs),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _MileageDynamics(mileage: mileage, fuel: fuel),
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

final class _FrequentRepairs extends StatelessWidget {
  const _FrequentRepairs({required this.repairs});

  final RepairAnalytics repairs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FREQUENT REPAIRS',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.7,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final repair in repairs.mostFrequentTypes) ...[
          _MetricBullet(label: repair.label, value: '${repair.count}'),
          if (repair != repairs.mostFrequentTypes.last)
            const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${repairs.count} total repair records',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

final class _MileageDynamics extends StatelessWidget {
  const _MileageDynamics({required this.mileage, required this.fuel});

  final MileageAnalytics mileage;
  final FuelAnalytics fuel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MILEAGE DYNAMICS',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.7,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '+${_formatNumber(mileage.monthlyDeltaKm)} km/mo',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryLight,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Up ${_formatDecimal(mileage.growthPercent)}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${_formatDecimal(fuel.averageConsumptionPer100Km)} L / 100 km',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.success,
              ),
        ),
      ],
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
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
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
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryLight,
                ),
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
  const _AnalyticsEmptyState({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
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
              'Not enough data for analytics',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              summary.message ??
                  'Add trips, refueling, repairs, or maintenance records.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _SuggestionChip(label: 'Add trip'),
                _SuggestionChip(label: 'Add refueling'),
                _SuggestionChip(label: 'Add repair'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load analytics',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
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
  });

  final List<AnalyticsChartPoint> points;
  final Color accentColor;
  final _ChartType type;
  final bool showLabels;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.isEmpty) {
      return;
    }

    final chartHeight = showLabels ? size.height - 26 : size.height;
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = chartHeight * index / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = points
        .map((point) => point.value)
        .reduce(math.max)
        .clamp(1, double.infinity)
        .toDouble();

    switch (type) {
      case _ChartType.bar:
        _drawBars(canvas, size, chartHeight, maxValue);
      case _ChartType.line:
        _drawLine(canvas, size, chartHeight, maxValue);
    }

    if (showLabels) {
      _drawLabels(canvas, size, chartHeight);
    }
  }

  void _drawBars(
      Canvas canvas, Size size, double chartHeight, double maxValue) {
    final slotWidth = size.width / points.length;
    final barWidth = math.min(42.0, slotWidth * 0.62);
    final paint = Paint()..color = accentColor.withValues(alpha: 0.72);

    for (var index = 0; index < points.length; index++) {
      final value = points[index].value;
      final barHeight = chartHeight * (value / maxValue);
      final left = (slotWidth * index) + ((slotWidth - barWidth) / 2);
      final top = chartHeight - barHeight;
      final rect = Rect.fromLTWH(left, top, barWidth, barHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        paint,
      );
    }
  }

  void _drawLine(
      Canvas canvas, Size size, double chartHeight, double maxValue) {
    final path = Path();
    final fillPath = Path();
    final step = points.length == 1 ? 0.0 : size.width / (points.length - 1);

    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1 ? size.width / 2 : step * index;
      final y = chartHeight - (chartHeight * points[index].value / maxValue);
      final offset = Offset(x, y);

      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
        fillPath
          ..moveTo(offset.dx, chartHeight)
          ..lineTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
        fillPath.lineTo(offset.dx, offset.dy);
      }

      canvas.drawCircle(offset, 4, Paint()..color = accentColor);
    }

    fillPath
      ..lineTo(size.width, chartHeight)
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

  void _drawLabels(Canvas canvas, Size size, double chartHeight) {
    final slotWidth = size.width / points.length;

    for (var index = 0; index < points.length; index++) {
      final painter = TextPainter(
        text: TextSpan(
          text: points[index].label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: slotWidth);
      final x = (slotWidth * index) + ((slotWidth - painter.width) / 2);
      painter.paint(canvas, Offset(x, chartHeight + AppSpacing.sm));
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsChartPainter oldDelegate) {
    return points != oldDelegate.points ||
        accentColor != oldDelegate.accentColor ||
        type != oldDelegate.type ||
        showLabels != oldDelegate.showLabels;
  }
}

String _periodLabel(AnalyticsPeriod period) {
  return switch (period) {
    AnalyticsPeriod.month => 'MONTH',
    AnalyticsPeriod.year => 'YEAR',
    AnalyticsPeriod.all => 'ALL TIME',
  };
}

String _periodAdjective(AnalyticsPeriod period) {
  return switch (period) {
    AnalyticsPeriod.month => 'MONTHLY',
    AnalyticsPeriod.year => 'ANNUAL',
    AnalyticsPeriod.all => 'ALL-TIME',
  };
}

String _periodNoun(AnalyticsPeriod period) {
  return switch (period) {
    AnalyticsPeriod.month => 'MONTHLY',
    AnalyticsPeriod.year => 'PERIOD',
    AnalyticsPeriod.all => 'ALL-TIME',
  };
}

String _categoryLabel(ExpenseCategory category) {
  return switch (category) {
    ExpenseCategory.fuel => 'Fuel',
    ExpenseCategory.repair => 'Repair',
    ExpenseCategory.maintenance => 'Maintenance',
    ExpenseCategory.parts => 'Parts',
    ExpenseCategory.washing => 'Washing',
    ExpenseCategory.other => 'Other',
  };
}

String _formatMoney(int amount) {
  return '${_formatNumber(amount)} ₽';
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
