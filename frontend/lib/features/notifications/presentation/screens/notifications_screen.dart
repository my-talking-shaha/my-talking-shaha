import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_card.dart';
import 'package:go_router/go_router.dart';

final class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: notificationsState.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const _NotificationsEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () => ref.refresh(notificationsProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () =>
                        context.push('/notifications/${notification.id}'),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemCount: notifications.length,
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              key: ValueKey('notifications_loading_state'),
            ),
          ),
          error: (error, stackTrace) => _NotificationsErrorState(
            onRetry: () => ref.invalidate(notificationsProvider),
          ),
        ),
      ),
    );
  }
}

final class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text('No notifications yet'),
      ),
    );
  }
}

final class _NotificationsErrorState extends StatelessWidget {
  const _NotificationsErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.error,
              size: 44,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Network error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Notifications could not be loaded. Check the connection and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              key: const ValueKey('notifications_retry_action'),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
