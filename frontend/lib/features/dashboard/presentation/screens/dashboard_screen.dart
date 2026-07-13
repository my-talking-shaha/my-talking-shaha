import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/dashboard/di/dashboard_providers.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_actions.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_unavailable.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    required this.vehicleId,
    this.launchedFromChat = false,
    super.key,
  });

  final String vehicleId;
  final bool launchedFromChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboardState = ref.watch(vehicleDashboardProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => DashboardActions.goBack(
            context,
            vehicleId: vehicleId,
            launchedFromChat: launchedFromChat,
          ),
          tooltip: launchedFromChat ? 'Back to chat' : l10n.openGarage,
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
        ),
        title: Text(l10n.myShaha),
      ),
      body: dashboardState.when(
        data: (dashboard) => DashboardContent(dashboard: dashboard),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => DashboardUnavailable(
          message: l10n.couldNotLoadDashboard,
          onAction: () => DashboardActions.retry(ref, vehicleId),
          actionLabel: l10n.retry,
        ),
      ),
    );
  }
}
