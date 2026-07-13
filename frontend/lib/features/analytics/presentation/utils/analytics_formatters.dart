import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';

String formatAnalyticsMoney(int amount) => '${formatAnalyticsNumber(amount)} ₽';

String formatAnalyticsCompactMoney(double value) {
  return '${formatAnalyticsCompactNumber(value)} ₽';
}

String formatAnalyticsCompactKilometers(double value) {
  return '${formatAnalyticsCompactNumber(value)} km';
}

String formatAnalyticsCompactNumber(double value) {
  final absValue = value.abs();
  if (absValue >= 1000000) {
    return '${_formatCompactDecimal(value / 1000000)}M';
  }
  if (absValue >= 1000) {
    return '${_formatCompactDecimal(value / 1000)}K';
  }
  return formatAnalyticsNumber(value);
}

String _formatCompactDecimal(double value) {
  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return rounded.round().toString();
  }
  return rounded.toStringAsFixed(1);
}

String formatAnalyticsNumber(num value) {
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

String formatAnalyticsDecimal(double value) {
  final fixed = value.toStringAsFixed(1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}

String analyticsDateRangeLabel(AnalyticsDateRange dateRange) {
  return '${_dateLabel(dateRange.startDate)} - ${_dateLabel(dateRange.endDate)}';
}

String _dateLabel(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
