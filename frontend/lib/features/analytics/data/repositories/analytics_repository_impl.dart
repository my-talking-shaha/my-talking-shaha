import 'package:frontend/features/analytics/data/datasources/analytics_datasource.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/domain/entities/mileage_trend.dart';
import 'package:frontend/features/analytics/domain/repositories/analytics_repository.dart';

final class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl(this._datasource);

  final AnalyticsDatasource _datasource;

  @override
  Future<AnalyticsSummary> getSummary({
    required String vehicleId,
    required AnalyticsPeriod period,
    AnalyticsDateRange? dateRange,
  }) {
    return _datasource.getSummary(
      vehicleId: vehicleId,
      period: period,
      dateRange: dateRange,
    );
  }

  @override
  Future<MileageTrend> getMileageTrend({
    required String vehicleId,
    required MileageTrendFilter filter,
  }) {
    return _datasource.getMileageTrend(vehicleId: vehicleId, filter: filter);
  }
}
