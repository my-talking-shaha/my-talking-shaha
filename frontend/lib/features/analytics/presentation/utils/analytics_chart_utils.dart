import 'dart:math' as math;

import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';

double analyticsNiceAxisMax(double value) {
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

double analyticsAverageValue(List<AnalyticsChartPoint> points) {
  if (points.isEmpty) {
    return 0;
  }

  final total = points.fold<double>(0, (sum, point) => sum + point.value);
  return total / points.length;
}
