import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/presentation/colors.dart';
import 'package:frontend/features/analytics/presentation/common/analytics_common_widgets.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_chart_utils.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_formatters.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

enum AnalyticsChartType { bar, line }

final class AnalyticsChartCard extends StatelessWidget {
  const AnalyticsChartCard({
    required this.points,
    required this.valueFormatter,
    required this.legend,
    required this.accentColor,
    this.chartType = AnalyticsChartType.bar,
    this.trendPercent,
    this.labelFormatter,
    this.axisValueFormatter,
    super.key,
  });

  final List<AnalyticsChartPoint> points;
  final String Function(double value) valueFormatter;
  final String legend;
  final Color accentColor;
  final AnalyticsChartType chartType;
  final double? trendPercent;
  final String Function(String label)? labelFormatter;
  final String Function(double value)? axisValueFormatter;

  @override
  Widget build(BuildContext context) {
    final average = analyticsAverageValue(points);

    return AnalyticsDashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: AnalyticsChartPainter(
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
                  color: AnalyticsColors.primaryLight,
                ),
              ),
              if (trendPercent case final trend?) ...[
                const SizedBox(width: AppSpacing.sm),
                AnalyticsTrendBadge(percent: trend),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

final class AnalyticsChartPainter extends CustomPainter {
  const AnalyticsChartPainter({
    required this.points,
    required this.accentColor,
    required this.type,
    this.showLabels = true,
    this.labelFormatter,
    this.valueFormatter = formatAnalyticsCompactNumber,
  });

  final List<AnalyticsChartPoint> points;
  final Color accentColor;
  final AnalyticsChartType type;
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

    final maxValue = analyticsNiceAxisMax(
      points.map((point) => point.value).reduce(math.max),
    );

    _drawValueAxis(canvas, plotRect, maxValue);

    final gridPaint = Paint()
      ..color = AnalyticsColors.border.withValues(alpha: 0.6)
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
      case AnalyticsChartType.bar:
        _drawBars(canvas, plotRect, maxValue);
      case AnalyticsChartType.line:
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
            color: AnalyticsColors.textSecondary,
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
            color: AnalyticsColors.textSecondary,
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
  bool shouldRepaint(covariant AnalyticsChartPainter oldDelegate) {
    return points != oldDelegate.points ||
        accentColor != oldDelegate.accentColor ||
        type != oldDelegate.type ||
        showLabels != oldDelegate.showLabels ||
        labelFormatter != oldDelegate.labelFormatter ||
        valueFormatter != oldDelegate.valueFormatter;
  }
}
