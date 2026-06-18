import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GarageHeader(onAddVehicle: () => context.go('/garage/add')),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: vehiclesState.when(
                  data: (vehicles) {
                    if (vehicles.isEmpty) {
                      return GarageEmptyState(
                        onAddVehicle: () => context.go('/garage/add'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                      itemCount: vehicles.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.xl),
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];

                        return VehicleGarageCard(
                          vehicle: vehicle,
                          onOpen: () {
                            context.go('/vehicle/${vehicle.id}/chat');
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
}

final class _GarageHeader extends StatelessWidget {
  const _GarageHeader({required this.onAddVehicle});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Talking Shaha',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: const Color(0xFFB8C3FF),
            fontSize: 31,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 42),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR FLEET',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Garage',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 56,
              height: 56,
              child: IconButton.filled(
                tooltip: 'Add vehicle',
                onPressed: onAddVehicle,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.add, size: 32),
              ),
            ),
          ],
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
