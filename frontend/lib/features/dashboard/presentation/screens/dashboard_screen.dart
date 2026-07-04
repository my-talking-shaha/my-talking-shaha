import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_unavailable.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

final class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboardState = ref.watch(vehicleDashboardProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/garage'),
          tooltip: l10n.openGarage,
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
        ),
        title: Text(l10n.myShaha),
      ),
      body: dashboardState.when(
        data: (dashboard) => DashboardContent(dashboard: dashboard),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => DashboardUnavailable(
          message: l10n.couldNotLoadDashboard,
          onAction: () {
            unawaited(ref.refresh(vehicleDashboardProvider(vehicleId).future));
          },
          actionLabel: l10n.retry,
        ),
      ),
    );
  }
}
