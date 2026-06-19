import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/presentation/providers/parts_providers.dart';
import 'package:frontend/features/parts/presentation/widgets/maintenance_forecast_card.dart';
import 'package:go_router/go_router.dart';

final class PartsScreen extends ConsumerWidget {
  const PartsScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsState = ref.watch(vehiclePartsProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parts lifetime widget example'),
        leading: IconButton(
          onPressed: () => context.go('/garage'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: partsState.when(
        data: (parts) {
          if (parts.isEmpty) {
            return const _PartsEmptyState();
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
              children: [
                Text(
                  vehicleId,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                MaintenanceForecastCard(parts: parts),
              ],
            ),
          );
        },
        loading: () => const _PartsLoadingState(),
        error: (error, stackTrace) {
          return _PartsErrorState(
            onRetry: () {
              ref.invalidate(vehiclePartsProvider(vehicleId));
            },
          );
        },
      ),
    );
  }
}

final class _PartsLoadingState extends StatelessWidget {
  const _PartsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('parts_loading_state'),
      child: CircularProgressIndicator(),
    );
  }
}

final class _PartsEmptyState extends StatelessWidget {
  const _PartsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('parts_empty_state'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.build_circle_outlined,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No parts added',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'When part lifetime data appears, the maintenance forecast '
              'will be shown here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

final class _PartsErrorState extends StatelessWidget {
  const _PartsErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('parts_error_state'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 42),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Could not load parts lifetime',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try again to refresh the maintenance forecast.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              key: const ValueKey('parts_retry_action'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
