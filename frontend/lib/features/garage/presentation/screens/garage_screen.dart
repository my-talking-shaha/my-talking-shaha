import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';
import 'package:frontend/features/garage/presentation/widgets/garage_empty_state.dart';
import 'package:frontend/features/garage/presentation/widgets/vehicle_garage_card.dart';
import 'package:go_router/go_router.dart';

final class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesState = ref.watch(garageControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              _GarageHeader(onAddVehicle: () => context.go('/garage/add')),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: vehiclesState.when(
                  data: (vehicles) {
                    if (vehicles.isEmpty) {
                      return GarageEmptyState(
                        onAddVehicle: () => context.go('/garage/add'),
                      );
                    }

                    return ListView.separated(
                      itemCount: vehicles.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];

                        return VehicleGarageCard(
                          vehicle: vehicle,
                          onOpen: () {
                            context.go('/vehicle/${vehicle.id}/chat');
                          },
                          onDelete: () => _confirmDelete(
                            context,
                            ref,
                            vehicle,
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => _GarageErrorState(
                    onRetry: () {
                      unawaited(
                        ref.read(garageControllerProvider.notifier).reload(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete vehicle?'),
          content: Text(
            '${vehicle.brand} ${vehicle.model} will be removed from the garage.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(garageControllerProvider.notifier).deleteVehicle(vehicle.id);
  }
}

final class _GarageHeader extends StatelessWidget {
  const _GarageHeader({required this.onAddVehicle});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Talking Shaha',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('YOUR FLEET', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Text('Garage', style: Theme.of(context).textTheme.headlineLarge),
            ],
          ),
        ),
        IconButton.filled(
          tooltip: 'Add vehicle',
          onPressed: onAddVehicle,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

final class _GarageErrorState extends StatelessWidget {
  const _GarageErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Could not load garage',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
