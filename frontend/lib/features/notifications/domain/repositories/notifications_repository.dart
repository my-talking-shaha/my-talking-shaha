import 'package:frontend/features/notifications/domain/entities/app_notification.dart';

abstract interface class NotificationsRepository {
  Future<List<AppNotification>> getNotifications();
}
