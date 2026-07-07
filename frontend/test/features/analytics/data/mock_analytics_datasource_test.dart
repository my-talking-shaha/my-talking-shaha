import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/analytics/data/datasources/mock_analytics_datasource.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/mileage_trend.dart';

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
    expect(summary.message, isNull);
  });

  test('returns filtered mocked mileage trends', () async {
    final datasource = MockAnalyticsDatasource(delay: Duration.zero);

    final yearTrend = await datasource.getMileageTrend(
      vehicleId: 'vehicle_1',
      filter: const MileageTrendFilter(year: 2026),
    );
    final monthTrend = await datasource.getMileageTrend(
      vehicleId: 'vehicle_1',
      filter: const MileageTrendFilter(year: 2026, month: 6),
    );

    expect(yearTrend.hasData, isTrue);
    expect(yearTrend.month, isNull);
    expect(yearTrend.points, hasLength(12));
    expect(yearTrend.points.first.label, 'Jan');

    expect(monthTrend.hasData, isTrue);
    expect(monthTrend.month, 6);
    expect(monthTrend.points.first.label, '1');
    expect(
      monthTrend.points.last.mileageKm,
      greaterThan(monthTrend.points.first.mileageKm),
    );
  });
}
