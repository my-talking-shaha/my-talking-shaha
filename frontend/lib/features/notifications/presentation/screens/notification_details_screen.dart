import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';
import 'package:frontend/features/notifications/presentation/providers/notifications_providers.dart';

final class NotificationDetailsScreen extends ConsumerWidget {
  const NotificationDetailsScreen({required this.notificationId, super.key});

  final String notificationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState =
        ref.watch(notificationByIdProvider(notificationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Notification details')),
      body: SafeArea(
        child: notificationState.when(
          data: (notification) {
            if (notification == null) {
              return const _NotificationNotFoundState();
            }

            return _NotificationDetails(notification: notification);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _NotificationDetailsErrorState(
            onRetry: () =>
                ref.invalidate(notificationByIdProvider(notificationId)),
          ),
        ),
      ),
    );
  }
}

final class _NotificationDetails extends StatelessWidget {
  const _NotificationDetails({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
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
                  _dateLabel(notification.createdAt),
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
                    _DetailRow(
                      label: 'Remaining resource',
                      value: '${notification.remainingKm} km',
                    ),
                  if (notification.recommendedAction != null)
                    _DetailRow(
                      label: 'Recommended action',
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

final class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

final class _NotificationNotFoundState extends StatelessWidget {
  const _NotificationNotFoundState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text('Notification was not found'),
      ),
    );
  }
}

final class _NotificationDetailsErrorState extends StatelessWidget {
  const _NotificationDetailsErrorState({required this.onRetry});

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
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _dateLabel(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day.$month.$year, $hour:$minute';
}
