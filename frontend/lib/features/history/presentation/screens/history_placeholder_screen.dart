import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class HistoryPlaceholderScreen extends StatelessWidget {
  const HistoryPlaceholderScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service history')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _HistoryEmptyState(vehicleId: vehicleId),
        ),
      ),
    );
  }
}

final class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, color: AppColors.primaryLight, size: 48),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'History is coming',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Trips, refueling, repairs, and maintenance will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
