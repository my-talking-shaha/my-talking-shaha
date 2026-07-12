import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/notifications/di/notifications_providers.dart';
import 'package:frontend/features/notifications/presentation/common/notification_centered_text.dart';
import 'package:frontend/features/notifications/presentation/common/notification_error_state.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_details_content.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class NotificationDetailsScreen extends ConsumerWidget {
  const NotificationDetailsScreen({required this.notificationId, super.key});

  final String notificationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notificationState = ref.watch(
      notificationByIdProvider(notificationId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationDetails)),
      body: SafeArea(
        child: notificationState.when(
          data: (notification) {
            if (notification == null) {
              return NotificationCenteredText(text: l10n.notificationNotFound);
            }

            return NotificationDetailsContent(notification: notification);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => NotificationErrorState(
            title: l10n.networkError,
            retryLabel: l10n.retry,
            onRetry: () =>
                ref.invalidate(notificationByIdProvider(notificationId)),
          ),
        ),
      ),
    );
  }
}
