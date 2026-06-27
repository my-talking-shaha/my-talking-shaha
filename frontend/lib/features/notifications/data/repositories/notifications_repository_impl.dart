import 'package:frontend/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';
import 'package:frontend/features/notifications/domain/repositories/notifications_repository.dart';

final class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._datasource);

  final NotificationsDatasource _datasource;

  @override
  Future<List<AppNotification>> getNotifications() {
    return _datasource.getNotifications();
  }
}
