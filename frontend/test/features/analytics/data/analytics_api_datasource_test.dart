import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/analytics/data/datasources/analytics_api_datasource.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';

void main() {
  group('AnalyticsApiSummaryMapper', () {
    test('maps backend analytics overview to domain summary', () {
      final summary = AnalyticsApiSummaryMapper.fromJson(
        const {
          'period': 'YEAR',
          'totalExpenses': 342500,
          'currency': 'RUB',
          'expensesByCategory': {
            'FUEL': 112500,
            'MAINTENANCE': 56000,
            'PARTS': 174000,
          },
          'monthlyExpenses': [
            {
              'month': '2026-06',
              'total': 15650,
              'breakdownByCategory': {
                'FUEL': 2450,
                'MAINTENANCE': 8900,
                'PARTS': 4300,
              },
            },
          ],
          'seasonalExpenses': [
            {'season': 'SUMMER', 'total': 15650},
          ],
          'costPerKilometer': {
            'totalKm': 1240,
            'totalExpenses': 15650,
            'costPerKm': 12.62,
          },
          'fuel': {
            'totalLiters': 120.4,
            'averageConsumptionLitersPer100Km': 7.2,
          },
          'historyAnalysis': {
            'eventCount': 7,
            'refuelCount': 2,
            'tripCount': 1,
            'maintenanceCount': 3,
            'partEventCount': 1,
            'totalTripKm': 1240,
            'averageTripKm': 1240,
          },
          'hasData': true,
        },
        fallbackPeriod: AnalyticsPeriod.month,
      );

      expect(summary.period, AnalyticsPeriod.year);
      expect(summary.hasEnoughData, isTrue);
      expect(summary.totalExpenses?.amount, 342500);
      expect(summary.totalExpenses?.currency, 'RUB');
      expect(summary.expensesByCategory, hasLength(3));
      expect(summary.expensesByCategory.first.category, ExpenseCategory.fuel);
      expect(summary.mileage?.totalKm, 1240);
      expect(summary.mileage?.costPerKm, 12.62);
      expect(summary.fuel?.averageConsumptionPer100Km, 7.2);
      expect(summary.repairs?.count, 4);
      expect(summary.history?.subscriptionCount, 2);
      expect(summary.history?.electronicsCount, 1);
      expect(summary.charts?.expensesByMonth.single.label, '06');
      expect(summary.charts?.expensesByMonth.single.value, 15650);
      expect(summary.charts?.mileageByMonth.single.label, 'Summer');
      expect(summary.charts?.repairsByMonth.single.value, 13200);
    });

    test('maps backend no-data response to insufficient-data state', () {
      final summary = AnalyticsApiSummaryMapper.fromJson(
        const {
          'period': 'ALL_TIME',
          'totalExpenses': 0,
          'currency': 'RUB',
          'expensesByCategory': <String, num>{},
          'monthlyExpenses': <Map<String, Object>>[],
          'seasonalExpenses': <Map<String, Object>>[],
          'costPerKilometer': {
            'totalKm': 0,
            'totalExpenses': 0,
            'costPerKm': 0,
          },
          'fuel': {
            'totalLiters': 0,
            'averageConsumptionLitersPer100Km': 0,
          },
          'historyAnalysis': {
            'eventCount': 0,
            'refuelCount': 0,
            'tripCount': 0,
            'maintenanceCount': 0,
            'partEventCount': 0,
            'totalTripKm': 0,
            'averageTripKm': 0,
          },
          'hasData': false,
        },
        fallbackPeriod: AnalyticsPeriod.year,
      );

      expect(summary.period, AnalyticsPeriod.all);
      expect(summary.hasEnoughData, isFalse);
      expect(summary.totalExpenses, isNull);
      expect(summary.message, contains('Not enough data'));
    });

    test('uses backend period query values', () {
      expect(
        AnalyticsApiSummaryMapper.periodQuery(AnalyticsPeriod.month),
        'MONTH',
      );
      expect(
        AnalyticsApiSummaryMapper.periodQuery(AnalyticsPeriod.year),
        'YEAR',
      );
      expect(
        AnalyticsApiSummaryMapper.periodQuery(AnalyticsPeriod.all),
        'ALL_TIME',
      );
    });
  });
}
