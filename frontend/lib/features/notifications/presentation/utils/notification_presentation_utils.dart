import 'package:flutter/material.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';
import 'package:frontend/features/notifications/presentation/colors.dart';

Color notificationAccentColor(AppNotificationType type) {
  return switch (type) {
    AppNotificationType.partLifetimeWarning => NotificationsColors.warning,
    AppNotificationType.maintenanceReminder => NotificationsColors.info,
    AppNotificationType.system => NotificationsColors.unread,
  };
}

IconData notificationIcon(AppNotificationType type) {
  return switch (type) {
    AppNotificationType.partLifetimeWarning => Icons.warning_amber_rounded,
    AppNotificationType.maintenanceReminder => Icons.build_circle_outlined,
    AppNotificationType.system => Icons.notifications_none_rounded,
  };
}

String notificationPreview(String description) {
  const maxLength = 118;
  final trimmed = description.trim();
  if (trimmed.length <= maxLength) return trimmed;

  return '${trimmed.substring(0, maxLength).trimRight()}...';
}

String notificationDateLabel(DateTime dateTime, {bool includeTime = false}) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  final date = '$day.$month.$year';

  if (!includeTime) return date;

  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$date, $hour:$minute';
}
