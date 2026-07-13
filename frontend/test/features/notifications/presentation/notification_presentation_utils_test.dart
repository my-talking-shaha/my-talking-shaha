import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';
import 'package:frontend/features/notifications/presentation/colors.dart';
import 'package:frontend/features/notifications/presentation/utils/notification_presentation_utils.dart';

void main() {
  test('preserves notification type colors and icons', () {
    expect(
      notificationAccentColor(AppNotificationType.partLifetimeWarning),
      NotificationsColors.warning,
    );
    expect(
      notificationAccentColor(AppNotificationType.maintenanceReminder),
      NotificationsColors.info,
    );
    expect(
      notificationAccentColor(AppNotificationType.system),
      NotificationsColors.unread,
    );
    expect(
      notificationIcon(AppNotificationType.partLifetimeWarning),
      Icons.warning_amber_rounded,
    );
    expect(
      notificationIcon(AppNotificationType.maintenanceReminder),
      Icons.build_circle_outlined,
    );
    expect(
      notificationIcon(AppNotificationType.system),
      Icons.notifications_none_rounded,
    );
  });

  test('preserves date and preview formatting', () {
    final date = DateTime.utc(2026, 6, 9, 7, 5);
    expect(notificationDateLabel(date), '09.06.2026');
    expect(notificationDateLabel(date, includeTime: true), '09.06.2026, 07:05');

    final longDescription = List.filled(119, 'a').join();
    final expectedPreview = '${List.filled(118, 'a').join()}...';
    expect(notificationPreview(longDescription), expectedPreview);
    expect(notificationPreview('  short message  '), 'short message');
  });
}
