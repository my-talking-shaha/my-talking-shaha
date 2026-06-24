import 'package:frontend/features/analytics/data/datasources/analytics_datasource.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';

final class MockAnalyticsDatasource implements AnalyticsDatasource {
  MockAnalyticsDatasource({this.delay = const Duration(milliseconds: 500)});

  final Duration delay;

  @override
  Future<AnalyticsSummary> getSummary({
    required String vehicleId,
    required AnalyticsPeriod period,
  }) async {
    await Future<void>.delayed(delay);

    if (vehicleId == 'vehicle_empty') {
      return _emptySummary(period);
    }

    return switch (period) {
      AnalyticsPeriod.month => _monthSummary(period),
      AnalyticsPeriod.year => _yearSummary(period),
      AnalyticsPeriod.all => _allTimeSummary(period),
    };
  }

  AnalyticsSummary _monthSummary(AnalyticsPeriod period) {
    return AnalyticsSummary(
      period: period,
      hasEnoughData: true,
      totalExpenses: const MoneyAmount(amount: 15650, currency: 'RUB'),
      trendPercent: 4.2,
      expensesByCategory: const [
        ExpenseCategoryAmount(category: ExpenseCategory.parts, amount: 6200),
        ExpenseCategoryAmount(
          category: ExpenseCategory.maintenance,
          amount: 3100,
        ),
        ExpenseCategoryAmount(category: ExpenseCategory.fuel, amount: 2450),
        ExpenseCategoryAmount(category: ExpenseCategory.other, amount: 3900),
      ],
      mileage: const MileageAnalytics(
        totalKm: 1240,
        costPerKm: 12.62,
        monthlyDeltaKm: 1240,
        growthPercent: 12,
      ),
      fuel: const FuelAnalytics(
        averageConsumptionPer100Km: 7.2,
        totalLiters: 120.4,
      ),
      repairs: const RepairAnalytics(
        count: 3,
        mostFrequentTypes: [
          RepairTypeMetric(label: 'Suspension', count: 4),
          RepairTypeMetric(label: 'Electrical', count: 2),
        ],
      ),
      maintenanceForecast: _maintenanceForecast(),
      history: _historyAnalytics(),
      charts: const AnalyticsCharts(
        expensesByMonth: [
          AnalyticsChartPoint(label: 'Jan', value: 24000),
          AnalyticsChartPoint(label: 'Feb', value: 30500),
          AnalyticsChartPoint(label: 'Mar', value: 18600),
          AnalyticsChartPoint(label: 'Apr', value: 41500),
          AnalyticsChartPoint(label: 'May', value: 36500),
          AnalyticsChartPoint(label: 'Jun', value: 15650),
        ],
        mileageByMonth: [
          AnalyticsChartPoint(label: 'Jan', value: 720),
          AnalyticsChartPoint(label: 'Feb', value: 880),
          AnalyticsChartPoint(label: 'Mar', value: 540),
          AnalyticsChartPoint(label: 'Apr', value: 1120),
          AnalyticsChartPoint(label: 'May', value: 940),
          AnalyticsChartPoint(label: 'Jun', value: 1240),
        ],
        repairsByMonth: [
          AnalyticsChartPoint(label: 'Jan', value: 1),
          AnalyticsChartPoint(label: 'Feb', value: 2),
          AnalyticsChartPoint(label: 'Mar', value: 1),
          AnalyticsChartPoint(label: 'Apr', value: 4),
          AnalyticsChartPoint(label: 'May', value: 3),
          AnalyticsChartPoint(label: 'Jun', value: 1),
        ],
      ),
    );
  }

  AnalyticsSummary _yearSummary(AnalyticsPeriod period) {
    return AnalyticsSummary(
      period: period,
      hasEnoughData: true,
      totalExpenses: const MoneyAmount(amount: 342500, currency: 'RUB'),
      trendPercent: 4.2,
      expensesByCategory: const [
        ExpenseCategoryAmount(category: ExpenseCategory.parts, amount: 145000),
        ExpenseCategoryAmount(category: ExpenseCategory.fuel, amount: 112500),
        ExpenseCategoryAmount(
          category: ExpenseCategory.maintenance,
          amount: 56000,
        ),
        ExpenseCategoryAmount(category: ExpenseCategory.other, amount: 29000),
      ],
      mileage: const MileageAnalytics(
        totalKm: 23840,
        costPerKm: 14.8,
        monthlyDeltaKm: 1240,
        growthPercent: 12,
      ),
      fuel: const FuelAnalytics(
        averageConsumptionPer100Km: 7.6,
        totalLiters: 1811.8,
      ),
      repairs: const RepairAnalytics(
        count: 18,
        mostFrequentTypes: [
          RepairTypeMetric(label: 'Suspension', count: 4),
          RepairTypeMetric(label: 'Electrical', count: 2),
        ],
      ),
      maintenanceForecast: _maintenanceForecast(),
      history: _historyAnalytics(),
      charts: const AnalyticsCharts(
        expensesByMonth: [
          AnalyticsChartPoint(label: 'Jul', value: 28500),
          AnalyticsChartPoint(label: 'Aug', value: 32400),
          AnalyticsChartPoint(label: 'Sep', value: 25500),
          AnalyticsChartPoint(label: 'Oct', value: 50600),
          AnalyticsChartPoint(label: 'Nov', value: 36500),
          AnalyticsChartPoint(label: 'Dec', value: 38900),
        ],
        mileageByMonth: [
          AnalyticsChartPoint(label: 'Jul', value: 960),
          AnalyticsChartPoint(label: 'Aug', value: 1280),
          AnalyticsChartPoint(label: 'Sep', value: 810),
          AnalyticsChartPoint(label: 'Oct', value: 1360),
          AnalyticsChartPoint(label: 'Nov', value: 1020),
          AnalyticsChartPoint(label: 'Dec', value: 1180),
        ],
        repairsByMonth: [
          AnalyticsChartPoint(label: 'Jul', value: 1),
          AnalyticsChartPoint(label: 'Aug', value: 2),
          AnalyticsChartPoint(label: 'Sep', value: 1),
          AnalyticsChartPoint(label: 'Oct', value: 4),
          AnalyticsChartPoint(label: 'Nov', value: 3),
          AnalyticsChartPoint(label: 'Dec', value: 1),
        ],
      ),
    );
  }

  AnalyticsSummary _allTimeSummary(AnalyticsPeriod period) {
    return AnalyticsSummary(
      period: period,
      hasEnoughData: true,
      totalExpenses: const MoneyAmount(amount: 916800, currency: 'RUB'),
      trendPercent: 8.7,
      expensesByCategory: const [
        ExpenseCategoryAmount(category: ExpenseCategory.parts, amount: 384000),
        ExpenseCategoryAmount(category: ExpenseCategory.fuel, amount: 292300),
        ExpenseCategoryAmount(
          category: ExpenseCategory.maintenance,
          amount: 151500,
        ),
        ExpenseCategoryAmount(category: ExpenseCategory.other, amount: 89000),
      ],
      mileage: const MileageAnalytics(
        totalKm: 67420,
        costPerKm: 13.6,
        monthlyDeltaKm: 1180,
        growthPercent: 9,
      ),
      fuel: const FuelAnalytics(
        averageConsumptionPer100Km: 7.4,
        totalLiters: 4989.1,
      ),
      repairs: const RepairAnalytics(
        count: 49,
        mostFrequentTypes: [
          RepairTypeMetric(label: 'Suspension', count: 12),
          RepairTypeMetric(label: 'Electrical', count: 8),
        ],
      ),
      maintenanceForecast: _maintenanceForecast(),
      history: _historyAnalytics(),
      charts: const AnalyticsCharts(
        expensesByMonth: [
          AnalyticsChartPoint(label: '2021', value: 168000),
          AnalyticsChartPoint(label: '2022', value: 201300),
          AnalyticsChartPoint(label: '2023', value: 219000),
          AnalyticsChartPoint(label: '2024', value: 186000),
          AnalyticsChartPoint(label: '2025', value: 142500),
        ],
        mileageByMonth: [
          AnalyticsChartPoint(label: '2021', value: 11200),
          AnalyticsChartPoint(label: '2022', value: 13980),
          AnalyticsChartPoint(label: '2023', value: 15140),
          AnalyticsChartPoint(label: '2024', value: 12820),
          AnalyticsChartPoint(label: '2025', value: 14280),
        ],
        repairsByMonth: [
          AnalyticsChartPoint(label: '2021', value: 8),
          AnalyticsChartPoint(label: '2022', value: 11),
          AnalyticsChartPoint(label: '2023', value: 12),
          AnalyticsChartPoint(label: '2024', value: 10),
          AnalyticsChartPoint(label: '2025', value: 8),
        ],
      ),
    );
  }

  AnalyticsSummary _emptySummary(AnalyticsPeriod period) {
    return AnalyticsSummary(
      period: period,
      hasEnoughData: false,
      totalExpenses: null,
      expensesByCategory: const [],
      mileage: null,
      fuel: null,
      repairs: null,
      maintenanceForecast: null,
      history: null,
      charts: null,
      trendPercent: null,
      message:
          'Not enough data for analytics yet. Add trips, refueling, repairs, '
          'or maintenance records to unlock insights.',
    );
  }

  AnalyticsMaintenanceForecast _maintenanceForecast() {
    return const AnalyticsMaintenanceForecast(
      remainingDistanceKm: 2400,
      approximateDateLabel: 'Jan 24, 2024 (45 days)',
      updatedLabel: 'Updated 2 hours ago',
      resourcePercent: 84,
      items: [
        AnalyticsMaintenanceItem(
          label: 'Brake pads',
          remainingPercent: 15,
          remainingDistanceKm: 3200,
          urgency: AnalyticsMaintenanceUrgency.warning,
        ),
        AnalyticsMaintenanceItem(
          label: 'Engine oil',
          remainingPercent: 5,
          remainingDistanceKm: 450,
          urgency: AnalyticsMaintenanceUrgency.critical,
        ),
        AnalyticsMaintenanceItem(
          label: 'Timing belt',
          remainingPercent: 0,
          remainingDistanceKm: 0,
          urgency: AnalyticsMaintenanceUrgency.critical,
        ),
      ],
    );
  }

  HistoryAnalytics _historyAnalytics() {
    return const HistoryAnalytics(
      companyMetrics: [
        CompanyMetric(label: 'Reliability', value: 92, maxValue: 100),
        CompanyMetric(label: 'Efficiency', value: 78, maxValue: 100),
      ],
      subscriptionCount: 4,
      electronicsCount: 2,
    );
  }
}
