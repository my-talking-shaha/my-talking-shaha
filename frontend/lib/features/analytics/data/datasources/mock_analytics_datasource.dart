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
      totalExpenses: const MoneyAmount(amount: 184950, currency: 'RUB'),
      trendPercent: 18.4,
      expensesByCategory: const [
        ExpenseCategoryAmount(category: ExpenseCategory.parts, amount: 84500),
        ExpenseCategoryAmount(
          category: ExpenseCategory.maintenance,
          amount: 41250,
        ),
        ExpenseCategoryAmount(category: ExpenseCategory.fuel, amount: 36700),
        ExpenseCategoryAmount(category: ExpenseCategory.other, amount: 22500),
      ],
      mileage: const MileageAnalytics(
        totalKm: 4320,
        costPerKm: 42.81,
        monthlyDeltaKm: 4320,
        growthPercent: 18,
      ),
      fuel: const FuelAnalytics(
        averageConsumptionPer100Km: 9.1,
        totalLiters: 393.2,
      ),
      repairs: const RepairAnalytics(
        count: 11,
        mostFrequentTypes: [
          RepairTypeMetric(label: 'Suspension', count: 5),
          RepairTypeMetric(label: 'Electrical', count: 3),
          RepairTypeMetric(label: 'Consumables', count: 3),
        ],
      ),
      maintenanceForecast: _maintenanceForecast(),
      history: _historyAnalytics(
        reliability: 78,
        efficiency: 69,
        maintenanceLoad: 86,
        refuels: 9,
        parts: 4,
      ),
      charts: const AnalyticsCharts(
        expensesByMonth: [
          AnalyticsChartPoint(label: 'Jun 1', value: 12600),
          AnalyticsChartPoint(label: 'Jun 4', value: 34200),
          AnalyticsChartPoint(label: 'Jun 8', value: 18400),
          AnalyticsChartPoint(label: 'Jun 12', value: 42100),
          AnalyticsChartPoint(label: 'Jun 16', value: 27800),
          AnalyticsChartPoint(label: 'Jun 20', value: 51600),
          AnalyticsChartPoint(label: 'Jun 24', value: 22900),
          AnalyticsChartPoint(label: 'Jun 28', value: 74650),
        ],
        mileageByMonth: [
          AnalyticsChartPoint(label: 'Jun 1', value: 380),
          AnalyticsChartPoint(label: 'Jun 4', value: 760),
          AnalyticsChartPoint(label: 'Jun 8', value: 520),
          AnalyticsChartPoint(label: 'Jun 12', value: 940),
          AnalyticsChartPoint(label: 'Jun 16', value: 430),
          AnalyticsChartPoint(label: 'Jun 20', value: 1120),
          AnalyticsChartPoint(label: 'Jun 24', value: 680),
          AnalyticsChartPoint(label: 'Jun 28', value: 1210),
        ],
        repairsByMonth: [
          AnalyticsChartPoint(label: 'Jun 1', value: 1),
          AnalyticsChartPoint(label: 'Jun 4', value: 2),
          AnalyticsChartPoint(label: 'Jun 8', value: 1),
          AnalyticsChartPoint(label: 'Jun 12', value: 3),
          AnalyticsChartPoint(label: 'Jun 16', value: 1),
          AnalyticsChartPoint(label: 'Jun 20', value: 4),
          AnalyticsChartPoint(label: 'Jun 24', value: 2),
          AnalyticsChartPoint(label: 'Jun 28', value: 5),
        ],
      ),
    );
  }

  AnalyticsSummary _yearSummary(AnalyticsPeriod period) {
    return AnalyticsSummary(
      period: period,
      hasEnoughData: true,
      totalExpenses: const MoneyAmount(amount: 1258700, currency: 'RUB'),
      trendPercent: 31.6,
      expensesByCategory: const [
        ExpenseCategoryAmount(category: ExpenseCategory.parts, amount: 531800),
        ExpenseCategoryAmount(category: ExpenseCategory.fuel, amount: 352400),
        ExpenseCategoryAmount(
          category: ExpenseCategory.maintenance,
          amount: 269700,
        ),
        ExpenseCategoryAmount(category: ExpenseCategory.other, amount: 104800),
      ],
      mileage: const MileageAnalytics(
        totalKm: 28640,
        costPerKm: 43.95,
        monthlyDeltaKm: 4320,
        growthPercent: 24,
      ),
      fuel: const FuelAnalytics(
        averageConsumptionPer100Km: 8.8,
        totalLiters: 2520.3,
      ),
      repairs: const RepairAnalytics(
        count: 43,
        mostFrequentTypes: [
          RepairTypeMetric(label: 'Suspension', count: 13),
          RepairTypeMetric(label: 'Electrical', count: 9),
          RepairTypeMetric(label: 'Brakes', count: 7),
        ],
      ),
      maintenanceForecast: _maintenanceForecast(),
      history: _historyAnalytics(
        reliability: 84,
        efficiency: 73,
        maintenanceLoad: 91,
        refuels: 52,
        parts: 17,
      ),
      charts: const AnalyticsCharts(
        expensesByMonth: [
          AnalyticsChartPoint(label: 'Jul', value: 74200),
          AnalyticsChartPoint(label: 'Aug', value: 93600),
          AnalyticsChartPoint(label: 'Sep', value: 68400),
          AnalyticsChartPoint(label: 'Oct', value: 155900),
          AnalyticsChartPoint(label: 'Nov', value: 88200),
          AnalyticsChartPoint(label: 'Dec', value: 119300),
          AnalyticsChartPoint(label: 'Jan', value: 104600),
          AnalyticsChartPoint(label: 'Feb', value: 137800),
          AnalyticsChartPoint(label: 'Mar', value: 96500),
          AnalyticsChartPoint(label: 'Apr', value: 173400),
          AnalyticsChartPoint(label: 'May', value: 161900),
          AnalyticsChartPoint(label: 'Jun', value: 184950),
        ],
        mileageByMonth: [
          AnalyticsChartPoint(label: 'Jul', value: 1640),
          AnalyticsChartPoint(label: 'Aug', value: 2320),
          AnalyticsChartPoint(label: 'Sep', value: 1740),
          AnalyticsChartPoint(label: 'Oct', value: 2860),
          AnalyticsChartPoint(label: 'Nov', value: 2180),
          AnalyticsChartPoint(label: 'Dec', value: 2510),
          AnalyticsChartPoint(label: 'Jan', value: 2060),
          AnalyticsChartPoint(label: 'Feb', value: 2780),
          AnalyticsChartPoint(label: 'Mar', value: 1950),
          AnalyticsChartPoint(label: 'Apr', value: 3220),
          AnalyticsChartPoint(label: 'May', value: 3060),
          AnalyticsChartPoint(label: 'Jun', value: 4320),
        ],
        repairsByMonth: [
          AnalyticsChartPoint(label: 'Jul', value: 2),
          AnalyticsChartPoint(label: 'Aug', value: 3),
          AnalyticsChartPoint(label: 'Sep', value: 2),
          AnalyticsChartPoint(label: 'Oct', value: 6),
          AnalyticsChartPoint(label: 'Nov', value: 4),
          AnalyticsChartPoint(label: 'Dec', value: 5),
          AnalyticsChartPoint(label: 'Jan', value: 3),
          AnalyticsChartPoint(label: 'Feb', value: 5),
          AnalyticsChartPoint(label: 'Mar', value: 3),
          AnalyticsChartPoint(label: 'Apr', value: 6),
          AnalyticsChartPoint(label: 'May', value: 4),
          AnalyticsChartPoint(label: 'Jun', value: 7),
        ],
      ),
    );
  }

  AnalyticsSummary _allTimeSummary(AnalyticsPeriod period) {
    return AnalyticsSummary(
      period: period,
      hasEnoughData: true,
      totalExpenses: const MoneyAmount(amount: 4862200, currency: 'RUB'),
      trendPercent: 42.9,
      expensesByCategory: const [
        ExpenseCategoryAmount(category: ExpenseCategory.parts, amount: 1974800),
        ExpenseCategoryAmount(category: ExpenseCategory.fuel, amount: 1432200),
        ExpenseCategoryAmount(
          category: ExpenseCategory.maintenance,
          amount: 1015600,
        ),
        ExpenseCategoryAmount(category: ExpenseCategory.other, amount: 439600),
      ],
      mileage: const MileageAnalytics(
        totalKm: 146870,
        costPerKm: 33.11,
        monthlyDeltaKm: 4320,
        growthPercent: 21,
      ),
      fuel: const FuelAnalytics(
        averageConsumptionPer100Km: 8.3,
        totalLiters: 12191.4,
      ),
      repairs: const RepairAnalytics(
        count: 164,
        mostFrequentTypes: [
          RepairTypeMetric(label: 'Suspension', count: 38),
          RepairTypeMetric(label: 'Electrical', count: 26),
          RepairTypeMetric(label: 'Engine', count: 19),
        ],
      ),
      maintenanceForecast: _maintenanceForecast(),
      history: _historyAnalytics(
        reliability: 88,
        efficiency: 81,
        maintenanceLoad: 94,
        refuels: 286,
        parts: 68,
      ),
      charts: const AnalyticsCharts(
        expensesByMonth: [
          AnalyticsChartPoint(label: '2020', value: 482000),
          AnalyticsChartPoint(label: '2021', value: 624500),
          AnalyticsChartPoint(label: '2022', value: 711300),
          AnalyticsChartPoint(label: '2023', value: 839400),
          AnalyticsChartPoint(label: '2024', value: 945600),
          AnalyticsChartPoint(label: '2025', value: 1000700),
          AnalyticsChartPoint(label: '2026', value: 1258700),
        ],
        mileageByMonth: [
          AnalyticsChartPoint(label: '2020', value: 16400),
          AnalyticsChartPoint(label: '2021', value: 19780),
          AnalyticsChartPoint(label: '2022', value: 21860),
          AnalyticsChartPoint(label: '2023', value: 24670),
          AnalyticsChartPoint(label: '2024', value: 26880),
          AnalyticsChartPoint(label: '2025', value: 28640),
          AnalyticsChartPoint(label: '2026', value: 28640),
        ],
        repairsByMonth: [
          AnalyticsChartPoint(label: '2020', value: 14),
          AnalyticsChartPoint(label: '2021', value: 18),
          AnalyticsChartPoint(label: '2022', value: 22),
          AnalyticsChartPoint(label: '2023', value: 27),
          AnalyticsChartPoint(label: '2024', value: 33),
          AnalyticsChartPoint(label: '2025', value: 39),
          AnalyticsChartPoint(label: '2026', value: 43),
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
      remainingDistanceKm: 620,
      approximateDateLabel: 'Jul 28, 2026 (24 days)',
      updatedLabel: 'Updated 14 minutes ago',
      resourcePercent: 22,
      items: [
        AnalyticsMaintenanceItem(
          label: 'Brake pads',
          remainingPercent: 12,
          remainingDistanceKm: 980,
          urgency: AnalyticsMaintenanceUrgency.warning,
        ),
        AnalyticsMaintenanceItem(
          label: 'Engine oil',
          remainingPercent: 4,
          remainingDistanceKm: 220,
          urgency: AnalyticsMaintenanceUrgency.critical,
        ),
        AnalyticsMaintenanceItem(
          label: 'Timing belt',
          remainingPercent: 0,
          remainingDistanceKm: 0,
          urgency: AnalyticsMaintenanceUrgency.critical,
        ),
        AnalyticsMaintenanceItem(
          label: 'Battery',
          remainingPercent: 28,
          remainingDistanceKm: 4200,
          urgency: AnalyticsMaintenanceUrgency.warning,
        ),
        AnalyticsMaintenanceItem(
          label: 'Cabin filter',
          remainingPercent: 66,
          remainingDistanceKm: 9200,
          urgency: AnalyticsMaintenanceUrgency.stable,
        ),
      ],
    );
  }

  HistoryAnalytics _historyAnalytics({
    required int reliability,
    required int efficiency,
    required int maintenanceLoad,
    required int refuels,
    required int parts,
  }) {
    return HistoryAnalytics(
      companyMetrics: [
        CompanyMetric(label: 'Reliability', value: reliability, maxValue: 100),
        CompanyMetric(label: 'Efficiency', value: efficiency, maxValue: 100),
        CompanyMetric(
          label: 'Maintenance load',
          value: maintenanceLoad,
          maxValue: 100,
        ),
      ],
      subscriptionCount: refuels,
      electronicsCount: parts,
    );
  }
}
