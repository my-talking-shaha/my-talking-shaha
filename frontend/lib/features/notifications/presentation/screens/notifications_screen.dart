import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/notifications/di/notifications_providers.dart';
import 'package:frontend/features/notifications/presentation/common/notification_centered_text.dart';
import 'package:frontend/features/notifications/presentation/common/notification_error_state.dart';
import 'package:frontend/features/notifications/presentation/widgets/notifications_list.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

final class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: SafeArea(
        child: notificationsState.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return NotificationCenteredText(text: l10n.noNotificationsYet);
            }

            return NotificationsList(
              notifications: notifications,
              onRefresh: () => ref.refresh(notificationsProvider.future),
              onNotificationTap: (notification) =>
                  context.push('/notifications/${notification.id}'),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              key: ValueKey('notifications_loading_state'),
            ),
          ),
          error: (error, stackTrace) => NotificationErrorState(
            title: l10n.networkError,
            message: l10n.notificationsLoadError,
            retryLabel: l10n.retry,
            retryKey: const ValueKey('notifications_retry_action'),
            onRetry: () => ref.invalidate(notificationsProvider),
          ),
        ),
      ),
    );
  }
}
