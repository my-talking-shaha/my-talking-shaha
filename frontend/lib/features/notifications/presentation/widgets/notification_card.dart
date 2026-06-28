import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';

final class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(notification.type);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(_icon(notification.type), color: accentColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _dateLabel(notification.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _shortDescription(notification.description),
                      key: ValueKey('notification_preview_${notification.id}'),
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (!notification.read) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _accentColor(AppNotificationType type) {
  return switch (type) {
    AppNotificationType.partLifetimeWarning => AppColors.warning,
    AppNotificationType.maintenanceReminder => AppColors.info,
    AppNotificationType.system => AppColors.primaryLight,
  };
}

IconData _icon(AppNotificationType type) {
  return switch (type) {
    AppNotificationType.partLifetimeWarning => Icons.warning_amber_rounded,
    AppNotificationType.maintenanceReminder => Icons.build_circle_outlined,
    AppNotificationType.system => Icons.notifications_none_rounded,
  };
}

String _shortDescription(String description) {
  const maxLength = 118;
  final trimmed = description.trim();
  if (trimmed.length <= maxLength) return trimmed;

  return '${trimmed.substring(0, maxLength).trimRight()}...';
}

String _dateLabel(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  return '$day.$month.$year';
}
