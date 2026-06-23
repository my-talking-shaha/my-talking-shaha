import 'package:frontend/features/dashboard/domain/entities/dashboard_data.dart';

abstract interface class DashboardRepository {
  Future<DashboardData> getDashboard(String vehicleId);
}
