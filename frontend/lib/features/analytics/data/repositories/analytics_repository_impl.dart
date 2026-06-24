import 'package:frontend/features/analytics/data/datasources/analytics_datasource.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/domain/repositories/analytics_repository.dart';

final class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl(this._datasource);

  final AnalyticsDatasource _datasource;

  @override
  Future<AnalyticsSummary> getSummary({
    required String vehicleId,
    required AnalyticsPeriod period,
  }) {
    return _datasource.getSummary(vehicleId: vehicleId, period: period);
  }
}
