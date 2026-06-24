import 'package:dio/dio.dart';
import 'package:frontend/features/analytics/data/datasources/analytics_datasource.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';

final class AnalyticsApiDatasource implements AnalyticsDatasource {
  const AnalyticsApiDatasource(this._dio);

  final Dio _dio;

  @override
  Future<AnalyticsSummary> getSummary({
    required String vehicleId,
    required AnalyticsPeriod period,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/vehicles/$vehicleId/analytics',
      queryParameters: {
        'period': AnalyticsApiSummaryMapper.periodQuery(period)
      },
    );

    return AnalyticsApiSummaryMapper.fromJson(
      response.data ?? const {},
      fallbackPeriod: period,
    );
  }
}

abstract final class AnalyticsApiSummaryMapper {
  static AnalyticsSummary fromJson(
    Map<String, dynamic> json, {
    required AnalyticsPeriod fallbackPeriod,
  }) {
    final hasData = _boolValue(json['hasData']);
    final period = _periodValue(json['period']) ?? fallbackPeriod;
    final monthlyExpenses = _mapListValue(json['monthlyExpenses']);
    final seasonalExpenses = _mapListValue(json['seasonalExpenses']);
    final costPerKilometer = _mapValue(json['costPerKilometer']);
    final fuel = _mapValue(json['fuel']);
    final historyAnalysis = _mapValue(json['historyAnalysis']);

    if (!hasData) {
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

    return AnalyticsSummary(
      period: period,
      hasEnoughData: true,
      totalExpenses: MoneyAmount(
        amount: _intValue(json['totalExpenses']),
        currency: _stringValue(json['currency'], fallback: 'RUB'),
      ),
      expensesByCategory: _expenseCategories(json['expensesByCategory']),
      mileage: MileageAnalytics(
        totalKm: _intValue(costPerKilometer['totalKm']),
        costPerKm: _doubleValue(costPerKilometer['costPerKm']),
        monthlyDeltaKm: _intValue(historyAnalysis['totalTripKm']),
        growthPercent: 0,
      ),
      fuel: FuelAnalytics(
        averageConsumptionPer100Km: _doubleValue(
          fuel['averageConsumptionLitersPer100Km'],
        ),
        totalLiters: _doubleValue(fuel['totalLiters']),
      ),
      repairs: RepairAnalytics(
        count: _intValue(historyAnalysis['maintenanceCount']) +
            _intValue(historyAnalysis['partEventCount']),
        mostFrequentTypes: [
          RepairTypeMetric(
            label: 'Maintenance',
            count: _intValue(historyAnalysis['maintenanceCount']),
          ),
          RepairTypeMetric(
            label: 'Parts',
            count: _intValue(historyAnalysis['partEventCount']),
          ),
        ],
      ),
      maintenanceForecast: null,
      history: HistoryAnalytics(
        companyMetrics: [
          CompanyMetric(
            label: 'Events',
            value: _intValue(historyAnalysis['eventCount']),
            maxValue: _metricMaxValue(historyAnalysis['eventCount']),
          ),
          CompanyMetric(
            label: 'Trip km',
            value: _intValue(historyAnalysis['totalTripKm']),
            maxValue: _metricMaxValue(historyAnalysis['totalTripKm']),
          ),
        ],
        subscriptionCount: _intValue(historyAnalysis['refuelCount']),
        electronicsCount: _intValue(historyAnalysis['partEventCount']),
      ),
      charts: AnalyticsCharts(
        expensesByMonth: _monthlyExpensePoints(monthlyExpenses),
        mileageByMonth: _seasonalExpensePoints(seasonalExpenses),
        repairsByMonth: _monthlyRepairPoints(monthlyExpenses),
      ),
      trendPercent: null,
    );
  }

  static String periodQuery(AnalyticsPeriod period) {
    return switch (period) {
      AnalyticsPeriod.month => 'MONTH',
      AnalyticsPeriod.year => 'YEAR',
      AnalyticsPeriod.all => 'ALL_TIME',
    };
  }

  static List<ExpenseCategoryAmount> _expenseCategories(Object? value) {
    if (value is! Map) return const [];

    return value.entries
        .map(
          (entry) => ExpenseCategoryAmount(
            category: _expenseCategory(entry.key),
            amount: _intValue(entry.value),
          ),
        )
        .toList(growable: false);
  }

  static ExpenseCategory _expenseCategory(Object? value) {
    return switch (value?.toString().toUpperCase()) {
      'FUEL' => ExpenseCategory.fuel,
      'MAINTENANCE' || 'REPAIR' => ExpenseCategory.maintenance,
      'PARTS' || 'PART_REPLACEMENT' => ExpenseCategory.parts,
      _ => ExpenseCategory.other,
    };
  }

  static List<AnalyticsChartPoint> _monthlyExpensePoints(
    List<Map<String, dynamic>> months,
  ) {
    return months
        .map(
          (json) => AnalyticsChartPoint(
            label: _monthLabel(json['month']),
            value: _doubleValue(json['total']),
          ),
        )
        .toList(growable: false);
  }

  static List<AnalyticsChartPoint> _seasonalExpensePoints(
    List<Map<String, dynamic>> seasons,
  ) {
    return seasons
        .map(
          (json) => AnalyticsChartPoint(
            label: _seasonLabel(json['season']),
            value: _doubleValue(json['total']),
          ),
        )
        .toList(growable: false);
  }

  static List<AnalyticsChartPoint> _monthlyRepairPoints(
    List<Map<String, dynamic>> months,
  ) {
    return months.map((json) {
      final breakdown = _mapValue(json['breakdownByCategory']);
      final repairTotal = _doubleValue(breakdown['MAINTENANCE']) +
          _doubleValue(breakdown['PARTS']);

      return AnalyticsChartPoint(
        label: _monthLabel(json['month']),
        value: repairTotal,
      );
    }).toList(growable: false);
  }

  static AnalyticsPeriod? _periodValue(Object? value) {
    return switch (value?.toString().toUpperCase()) {
      'MONTH' => AnalyticsPeriod.month,
      'YEAR' => AnalyticsPeriod.year,
      'ALL_TIME' => AnalyticsPeriod.all,
      _ => null,
    };
  }

  static String _monthLabel(Object? value) {
    final stringValue = value?.toString() ?? '';
    if (stringValue.length == 7) {
      return stringValue.substring(5);
    }

    return stringValue;
  }

  static String _seasonLabel(Object? value) {
    final stringValue = value?.toString() ?? '';
    if (stringValue.isEmpty) return '';

    return stringValue[0] + stringValue.substring(1).toLowerCase();
  }

  static List<Map<String, dynamic>> _mapListValue(Object? value) {
    if (value is! List) return const [];

    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  static Map<String, dynamic> _mapValue(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    return const {};
  }

  static bool _boolValue(Object? value) {
    return switch (value) {
      bool boolValue => boolValue,
      String stringValue => stringValue.toLowerCase() == 'true',
      _ => false,
    };
  }

  static String _stringValue(Object? value, {required String fallback}) {
    final stringValue = value?.toString();
    return stringValue == null || stringValue.isEmpty ? fallback : stringValue;
  }

  static int _intValue(Object? value) {
    return switch (value) {
      int intValue => intValue,
      num numValue => numValue.round(),
      String stringValue => num.tryParse(stringValue)?.round() ?? 0,
      _ => 0,
    };
  }

  static int _metricMaxValue(Object? value) {
    final intValue = _intValue(value);
    if (intValue < 1) return 1;
    if (intValue > 100) return intValue;
    return 100;
  }

  static double _doubleValue(Object? value) {
    return switch (value) {
      double doubleValue => doubleValue,
      num numValue => numValue.toDouble(),
      String stringValue => double.tryParse(stringValue) ?? 0,
      _ => 0,
    };
  }
}
