import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/analytics/data/datasources/mock_analytics_datasource.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';

void main() {
  test('returns period-specific mocked analytics summaries', () async {
    final datasource = MockAnalyticsDatasource(delay: Duration.zero);

    final year = await datasource.getSummary(
      vehicleId: 'vehicle_1',
      period: AnalyticsPeriod.year,
    );
    final month = await datasource.getSummary(
      vehicleId: 'vehicle_1',
      period: AnalyticsPeriod.month,
    );

    expect(year.hasEnoughData, isTrue);
    expect(year.totalExpenses?.amount, 1258700);
    expect(year.charts?.expensesByMonth, hasLength(12));

    expect(month.hasEnoughData, isTrue);
    expect(month.totalExpenses?.amount, 184950);
    expect(month.mileage?.costPerKm, 42.81);
  });

  test('generates custom range mocked analytics from selected dates', () async {
    final datasource = MockAnalyticsDatasource(delay: Duration.zero);

    final summary = await datasource.getSummary(
      vehicleId: 'vehicle_1',
      period: AnalyticsPeriod.year,
      dateRange: AnalyticsDateRange(
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 10),
      ),
    );

    expect(summary.hasEnoughData, isTrue);
    expect(summary.totalExpenses?.amount, 82000);
    expect(summary.mileage?.totalKm, 960);
    expect(summary.charts?.expensesByMonth, isNotEmpty);
  });

  test('returns an explicit insufficient-data state', () async {
    final datasource = MockAnalyticsDatasource(delay: Duration.zero);

    final summary = await datasource.getSummary(
      vehicleId: 'vehicle_empty',
      period: AnalyticsPeriod.year,
    );

    expect(summary.hasEnoughData, isFalse);
    expect(summary.totalExpenses, isNull);
    expect(summary.message, contains('Not enough data'));
  });
}
