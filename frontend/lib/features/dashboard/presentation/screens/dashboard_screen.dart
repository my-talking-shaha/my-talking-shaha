import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_utils.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_unavailable.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';
import 'package:frontend/features/history/presentation/providers/history_providers.dart';
import 'package:go_router/go_router.dart';

final class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesState = ref.watch(garageControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/garage'),
          tooltip: 'Open garage',
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
        ),
        title: const Text('My Shaha'),
      ),
      body: vehiclesState.when(
        data: (vehicles) {
          final vehicle = DashboardUtils.findVehicle(vehicles, vehicleId);
          if (vehicle == null) {
            return DashboardUnavailable(
              message: 'Vehicle not found',
              onAction: () => context.go('/garage'),
              actionLabel: 'Open garage',
            );
          }

          return DashboardContent(
            vehicle: vehicle,
            eventsState: ref.watch(historyEventsProvider(vehicleId)),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => DashboardUnavailable(
          message: 'Could not load the dashboard',
          onAction: () {
            unawaited(ref.read(garageControllerProvider.notifier).reload());
          },
          actionLabel: 'Retry',
        ),
      ),
    );
  }
}
