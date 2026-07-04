import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/domain/entities/mileage_trend.dart';

abstract interface class AnalyticsDatasource {
  Future<AnalyticsSummary> getSummary({
    required String vehicleId,
    required AnalyticsPeriod period,
    AnalyticsDateRange? dateRange,
  });

  Future<MileageTrend> getMileageTrend({
    required String vehicleId,
    required MileageTrendFilter filter,
  });
}
