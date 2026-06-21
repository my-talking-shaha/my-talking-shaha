import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.primaryLight,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Analytics is coming',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Vehicle insights will appear here when the feature is ready.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
