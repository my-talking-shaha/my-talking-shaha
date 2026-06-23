import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';

final class DashboardData {
  const DashboardData({
    required this.vehicle,
    required this.maintenanceParts,
    required this.recentEvents,
  });

  final Vehicle vehicle;
  final List<VehiclePart> maintenanceParts;
  final List<DashboardRecentEvent> recentEvents;
}

final class DashboardRecentEvent {
  const DashboardRecentEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.occurredAt,
  });

  final String id;
  final HistoryEventType type;
  final String title;
  final String subtitle;
  final DateTime occurredAt;
}
