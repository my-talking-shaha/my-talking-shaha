import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/analytics/data/datasources/analytics_api_datasource.dart';
import 'package:frontend/features/analytics/data/datasources/analytics_datasource.dart';
import 'package:frontend/features/analytics/data/datasources/mock_analytics_datasource.dart';
import 'package:frontend/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/analytics/domain/repositories/analytics_repository.dart';

typedef AnalyticsSummaryRequest = ({String vehicleId, AnalyticsPeriod period});

final mockAnalyticsDatasourceProvider =
    Provider<MockAnalyticsDatasource>((ref) {
  return MockAnalyticsDatasource();
});

final analyticsApiDatasourceProvider = Provider<AnalyticsApiDatasource>((ref) {
  return AnalyticsApiDatasource(ref.watch(dioProvider));
});

final analyticsDatasourceProvider = Provider<AnalyticsDatasource>((ref) {
  return ref.watch(analyticsApiDatasourceProvider);
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(ref.watch(analyticsDatasourceProvider));
});

final analyticsSummaryProvider = FutureProvider.autoDispose
    .family<AnalyticsSummary, AnalyticsSummaryRequest>((ref, request) {
  return ref
      .watch(analyticsRepositoryProvider)
      .getSummary(vehicleId: request.vehicleId, period: request.period);
});
