import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';
import 'package:frontend/features/garage/presentation/widgets/vehicle_garage_card.dart';
import 'package:go_router/go_router.dart';

final class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesState = ref.watch(garageControllerProvider);

    return Scaffold(
      body: vehiclesState.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return _EmptyGarageBody(
              onAddVehicle: () => context.go('/garage/add'),
            );
          }

          return _GarageListBody(
            vehicles: vehicles,
            onAddVehicle: () => context.go('/garage/add'),
            onOpenVehicle: (vehicleId) {
              context.go('/vehicle/$vehicleId/chat');
            },
            onEditVehicle: (vehicleId) {
              context.go('/garage/edit/$vehicleId');
            },
            onDeleteVehicle: (vehicle) {
              unawaited(_confirmDelete(context, ref, vehicle));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _GarageErrorState(
          onRetry: () {
            unawaited(ref.read(garageControllerProvider.notifier).reload());
          },
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

final class _GarageListBody extends StatelessWidget {
  const _GarageListBody({
    required this.vehicles,
    required this.onAddVehicle,
    required this.onOpenVehicle,
    required this.onEditVehicle,
    required this.onDeleteVehicle,
  });

  final List<Vehicle> vehicles;
  final VoidCallback onAddVehicle;
  final ValueChanged<String> onOpenVehicle;
  final ValueChanged<String> onEditVehicle;
  final ValueChanged<Vehicle> onDeleteVehicle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            _GarageHeader(onAddVehicle: onAddVehicle),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                itemCount: vehicles.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xl),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];

                  return VehicleGarageCard(
                    vehicle: vehicle,
                    onOpen: () => onOpenVehicle(vehicle.id),
                    onEdit: () => onEditVehicle(vehicle.id),
                    onDelete: () => onDeleteVehicle(vehicle),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _EmptyGarageBody extends StatelessWidget {
  const _EmptyGarageBody({required this.onAddVehicle});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SvgPicture.asset(
          'assets/images/garage_bg.svg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
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
              const Spacer(flex: 5),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Garage is empty',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Add your first car to create its digital twin.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: onAddVehicle,
                          icon: const Icon(Icons.add_circle_outline, size: 22),
                          label: const Text('Add vehicle'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 8),
            ],
          ),
        ),
      ],
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
