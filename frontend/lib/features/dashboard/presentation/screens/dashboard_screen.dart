import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_unavailable.dart';
import 'package:go_router/go_router.dart';

final class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(vehicleDashboardProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/garage'),
          tooltip: 'Open garage',
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
        ),
        title: const Text('My Shaha'),
      ),
      body: dashboardState.when(
        data: (dashboard) => DashboardContent(dashboard: dashboard),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => DashboardUnavailable(
          message: 'Could not load the dashboard',
          onAction: () {
            unawaited(ref.refresh(vehicleDashboardProvider(vehicleId).future));
          },
          actionLabel: 'Retry',
        ),
      ),
    );
  }
}
