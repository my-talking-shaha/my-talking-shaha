import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/di/parts_providers.dart';
import 'package:frontend/features/parts/presentation/utils/parts_screen_actions.dart';
import 'package:frontend/features/parts/presentation/widgets/common/parts_async_states.dart';
import 'package:frontend/features/parts/presentation/widgets/maintenance_forecast_card.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class PartsScreen extends ConsumerWidget {
  const PartsScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final partsState = ref.watch(vehiclePartsProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.maintenanceForecast),
        leading: IconButton(
          onPressed: partsBackAction(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: partsState.when(
        data: (parts) {
          if (parts.isEmpty) {
            return const PartsEmptyState();
          }

          return SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              children: [MaintenanceForecastCard(parts: parts)],
            ),
          );
        },
        loading: () => const PartsLoadingState(),
        error: (error, stackTrace) {
          return PartsErrorState(onRetry: partsRetryAction(ref, vehicleId));
        },
      ),
    );
  }
}
