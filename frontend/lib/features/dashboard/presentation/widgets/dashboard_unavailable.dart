import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class DashboardUnavailable extends StatelessWidget {
  const DashboardUnavailable({
    required this.message,
    required this.onAction,
    required this.actionLabel,
    super.key,
  });

  final String message;
  final VoidCallback onAction;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_car_outlined,
              color: AppColors.primaryLight,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(message, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
