import 'package:frontend/features/notifications/domain/entities/app_notification.dart';

abstract interface class NotificationsDatasource {
  Future<List<AppNotification>> getNotifications();
}
