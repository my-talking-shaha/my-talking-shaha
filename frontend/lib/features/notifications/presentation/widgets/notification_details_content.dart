import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';
import 'package:frontend/features/notifications/presentation/utils/notification_presentation_utils.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_detail_row.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class NotificationDetailsContent extends StatelessWidget {
  const NotificationDetailsContent({required this.notification, super.key});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notificationDateLabel(
                    notification.createdAt,
                    includeTime: true,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  notification.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  notification.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (notification.remainingKm != null ||
                    notification.recommendedAction != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.lg),
                  if (notification.remainingKm != null)
                    NotificationDetailRow(
                      label: l10n.remainingResource,
                      value: '${notification.remainingKm} km',
                    ),
                  if (notification.recommendedAction != null)
                    NotificationDetailRow(
                      label: l10n.recommendedAction,
                      value: notification.recommendedAction!,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
