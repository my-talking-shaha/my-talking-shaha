import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_chart_utils.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_formatters.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_interactions.dart';

void main() {
  group('analytics formatters', () {
    test('preserve money, decimal, compact and date formatting', () {
      expect(formatAnalyticsMoney(1258700), '1,258,700 ₽');
      expect(formatAnalyticsMoney(1258700.75), '1,258,700.75 ₽');
      expect(formatAnalyticsNumber(-12345), '-12,345');
      expect(formatAnalyticsDecimal(14), '14');
      expect(formatAnalyticsDecimal(14.8), '14.8');
      expect(formatAnalyticsDecimal(14.85), '14.85');
      expect(formatAnalyticsCompactNumber(1250000), '1.3M');
      expect(formatAnalyticsCompactMoney(12500), '12.5K ₽');
      expect(formatAnalyticsCompactKilometers(1200), '1.2K km');
      expect(
        analyticsDateRangeLabel(
          AnalyticsDateRange(
            startDate: DateTime(2026, 1, 2),
            endDate: DateTime(2026, 6, 30),
          ),
        ),
        '02.01.2026 - 30.06.2026',
      );
    });
  });

  group('analytics chart utilities', () {
    test('preserve average and nice axis maximum calculations', () {
      expect(analyticsAverageValue(const []), 0);
      expect(
        analyticsAverageValue(const [
          AnalyticsChartPoint(label: 'A', value: 10),
          AnalyticsChartPoint(label: 'B', value: 20),
        ]),
        15,
      );
      expect(analyticsNiceAxisMax(0), 1);
      expect(analyticsNiceAxisMax(1.2), 2);
      expect(analyticsNiceAxisMax(6200), 10000);
    });
  });

  test('mileage years are current year plus four previous years', () {
    expect(analyticsMileageYearOptions(now: DateTime(2026, 7, 10)), [
      2026,
      2025,
      2024,
      2023,
      2022,
    ]);
  });
}
