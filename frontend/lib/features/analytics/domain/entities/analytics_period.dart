enum AnalyticsPeriod {
  month('month'),
  year('year'),
  all('all');

  const AnalyticsPeriod(this.queryValue);

  final String queryValue;
}

final class AnalyticsDateRange {
  const AnalyticsDateRange({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;

  @override
  bool operator ==(Object other) {
    return other is AnalyticsDateRange &&
        _sameDate(other.startDate, startDate) &&
        _sameDate(other.endDate, endDate);
  }

  @override
  int get hashCode => Object.hash(
    startDate.year,
    startDate.month,
    startDate.day,
    endDate.year,
    endDate.month,
    endDate.day,
  );

  static bool _sameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
