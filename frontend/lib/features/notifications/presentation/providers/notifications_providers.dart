import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/notifications/data/datasources/mock_notifications_datasource.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:frontend/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';
import 'package:frontend/features/notifications/domain/repositories/notifications_repository.dart';

final notificationsDatasourceProvider =
    Provider<NotificationsDatasource>((ref) {
  return const MockNotificationsDatasource();
});

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(
      ref.watch(notificationsDatasourceProvider));
});

final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((
  ref,
) {
  return ref.watch(notificationsRepositoryProvider).getNotifications();
});

final notificationByIdProvider = FutureProvider.autoDispose
    .family<AppNotification?, String>((ref, notificationId) async {
  final notifications = await ref.watch(notificationsProvider.future);

  for (final notification in notifications) {
    if (notification.id == notificationId) {
      return notification;
    }
  }

  return null;
});
