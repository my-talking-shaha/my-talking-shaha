import 'package:frontend/features/dashboard/data/datasources/dashboard_api_datasource.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:frontend/features/dashboard/domain/repositories/dashboard_repository.dart';

final class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._datasource);

  final DashboardApiDatasource _datasource;

  @override
  Future<DashboardData> getDashboard(String vehicleId) {
    return _datasource.getDashboard(vehicleId);
  }
}
