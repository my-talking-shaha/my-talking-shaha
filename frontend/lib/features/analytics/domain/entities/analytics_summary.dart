import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';

enum ExpenseCategory { fuel, maintenance, parts, other }

enum AnalyticsMaintenanceUrgency { stable, warning, critical }

final class MoneyAmount {
  const MoneyAmount({required this.amount, required this.currency});

  final int amount;
  final String currency;
}

final class ExpenseCategoryAmount {
  const ExpenseCategoryAmount({required this.category, required this.amount});

  final ExpenseCategory category;
  final int amount;
}

final class MileageAnalytics {
  const MileageAnalytics({
    required this.totalKm,
    required this.costPerKm,
    required this.monthlyDeltaKm,
    required this.growthPercent,
  });

  final int totalKm;
  final double costPerKm;
  final int monthlyDeltaKm;
  final double growthPercent;
}

final class FuelAnalytics {
  const FuelAnalytics({
    required this.averageConsumptionPer100Km,
    required this.totalLiters,
  });

  final double averageConsumptionPer100Km;
  final double totalLiters;
}

final class RepairAnalytics {
  const RepairAnalytics({required this.count, required this.mostFrequentTypes});

  final int count;
  final List<RepairTypeMetric> mostFrequentTypes;
}

final class RepairTypeMetric {
  const RepairTypeMetric({required this.label, required this.count});

  final String label;
  final int count;
}

final class AnalyticsMaintenanceForecast {
  const AnalyticsMaintenanceForecast({
    required this.remainingDistanceKm,
    required this.approximateDateLabel,
    required this.updatedLabel,
    required this.resourcePercent,
    required this.items,
  });

  final int remainingDistanceKm;
  final String approximateDateLabel;
  final String updatedLabel;
  final int resourcePercent;
  final List<AnalyticsMaintenanceItem> items;
}

final class AnalyticsMaintenanceItem {
  const AnalyticsMaintenanceItem({
    required this.label,
    required this.remainingPercent,
    required this.remainingDistanceKm,
    required this.urgency,
  });

  final String label;
  final int remainingPercent;
  final int remainingDistanceKm;
  final AnalyticsMaintenanceUrgency urgency;
}

final class HistoryAnalytics {
  const HistoryAnalytics({
    required this.companyMetrics,
    required this.subscriptionCount,
    required this.electronicsCount,
  });

  final List<CompanyMetric> companyMetrics;
  final int subscriptionCount;
  final int electronicsCount;
}

final class CompanyMetric {
  const CompanyMetric({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  final String label;
  final int value;
  final int maxValue;
}

final class AnalyticsChartPoint {
  const AnalyticsChartPoint({required this.label, required this.value});

  final String label;
  final double value;
}

final class AnalyticsCharts {
  const AnalyticsCharts({
    required this.expensesByMonth,
    required this.mileageByMonth,
    required this.repairsByMonth,
  });

  final List<AnalyticsChartPoint> expensesByMonth;
  final List<AnalyticsChartPoint> mileageByMonth;
  final List<AnalyticsChartPoint> repairsByMonth;
}

final class AnalyticsSummary {
  const AnalyticsSummary({
    required this.period,
    required this.hasEnoughData,
    required this.totalExpenses,
    required this.expensesByCategory,
    required this.mileage,
    required this.fuel,
    required this.repairs,
    required this.maintenanceForecast,
    required this.history,
    required this.charts,
    required this.trendPercent,
    this.message,
  });

  final AnalyticsPeriod period;
  final bool hasEnoughData;
  final MoneyAmount? totalExpenses;
  final List<ExpenseCategoryAmount> expensesByCategory;
  final MileageAnalytics? mileage;
  final FuelAnalytics? fuel;
  final RepairAnalytics? repairs;
  final AnalyticsMaintenanceForecast? maintenanceForecast;
  final HistoryAnalytics? history;
  final AnalyticsCharts? charts;
  final double? trendPercent;
  final String? message;
}
