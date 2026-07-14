import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_card.dart';

final class NotificationsList extends StatelessWidget {
  const NotificationsList({
    required this.notifications,
    required this.onRefresh,
    required this.onNotificationTap,
    super.key,
  });

  final List<AppNotification> notifications;
  final Future<void> Function() onRefresh;
  final ValueChanged<AppNotification> onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return NativeRefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () => onNotificationTap(notification),
          );
        },
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemCount: notifications.length,
      ),
    );
  }
}
