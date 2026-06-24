import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/dashboard/data/datasources/dashboard_api_datasource.dart';
import 'package:frontend/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:frontend/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardApiDatasourceProvider = Provider<DashboardApiDatasource>((ref) {
  return DashboardApiDatasource(ref.watch(dioProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardApiDatasourceProvider));
});

final vehicleDashboardProvider =
    FutureProvider.autoDispose.family<DashboardData, String>((ref, vehicleId) {
  return ref.watch(dashboardRepositoryProvider).getDashboard(vehicleId);
});
