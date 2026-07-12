import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/notifications/presentation/colors.dart';

final class NotificationErrorState extends StatelessWidget {
  const NotificationErrorState({
    required this.title,
    required this.retryLabel,
    required this.onRetry,
    this.message,
    this.retryKey,
    super.key,
  });

  final String title;
  final String? message;
  final String retryLabel;
  final VoidCallback onRetry;
  final Key? retryKey;

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
              color: NotificationsColors.error,
              size: 44,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              key: retryKey,
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
