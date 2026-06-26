import 'package:frontend/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';

final class MockNotificationsDatasource implements NotificationsDatasource {
  const MockNotificationsDatasource(
      {this.delay = const Duration(milliseconds: 300)});

  final Duration delay;

  @override
  Future<List<AppNotification>> getNotifications() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return [
      AppNotification(
        id: 'notif_engine_oil',
        vehicleId: 'vehicle_123',
        partId: 'part_engine_oil',
        type: AppNotificationType.partLifetimeWarning,
        title: 'Oil service is coming soon',
        description:
            'Engine oil has about 450 km of estimated lifetime left. Plan a service visit this week to avoid accelerated wear and keep the engine protected during daily driving.',
        remainingKm: 450,
        recommendedAction: 'Schedule an oil change',
        createdAt: DateTime.utc(2026, 6, 10, 10),
        read: false,
      ),
      AppNotification(
        id: 'notif_brake_pads',
        vehicleId: 'vehicle_123',
        partId: 'part_front_pads',
        type: AppNotificationType.partLifetimeWarning,
        title: 'Brake pads need attention',
        description:
            'Front brake pads are below the warning threshold. Check braking distance, avoid aggressive driving, and book diagnostics before the next long trip.',
        remainingKm: 220,
        recommendedAction: 'Inspect front brake pads',
        createdAt: DateTime.utc(2026, 6, 9, 16, 30),
        read: false,
      ),
      AppNotification(
        id: 'notif_battery',
        vehicleId: 'vehicle_123',
        partId: 'part_battery',
        type: AppNotificationType.maintenanceReminder,
        title: 'Battery health dropped',
        description:
            'Battery resource is trending down faster than expected. A quick voltage check can help prevent a failed start on cold mornings.',
        remainingKm: null,
        recommendedAction: 'Run battery diagnostics',
        createdAt: DateTime.utc(2026, 6, 7, 9, 15),
        read: true,
      ),
    ];
  }
}
