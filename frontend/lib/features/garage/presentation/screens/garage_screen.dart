import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        const _GarageEmptyBackground(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            MediaQuery.paddingOf(context).top + AppSpacing.lg,
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
              const Spacer(),
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
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}

final class _GarageEmptyBackground extends StatelessWidget {
  const _GarageEmptyBackground();

  static const double _assetWidth = 390;
  static const double _assetHeight = 884;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ColoredBox(
        color: AppColors.background,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = MediaQuery.sizeOf(context);
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : screenSize.width;
            final height = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : screenSize.height;
            final scale = math.max(width / _assetWidth, height / _assetHeight);
            final dx = (width - (_assetWidth * scale)) / 2;

            return Stack(
              fit: StackFit.expand,
              children: [
                _GarageBlurredGlow(
                  left: dx + (-200 * scale),
                  top: 101 * scale,
                  size: 496 * scale,
                  circleSize: 256 * scale,
                  blurSigma: 60 * scale,
                  color: const Color(0xFFB8C3FF).withValues(alpha: 0.20),
                ),
                _GarageBlurredGlow(
                  left: dx + (94 * scale),
                  top: 287 * scale,
                  size: 496 * scale,
                  circleSize: 256 * scale,
                  blurSigma: 60 * scale,
                  color: AppColors.success.withValues(alpha: 0.20),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0),
                        AppColors.background.withValues(alpha: 0.34),
                        AppColors.background.withValues(alpha: 0.64),
                      ],
                      stops: const [0, 0.72, 1],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

final class _GarageBlurredGlow extends StatelessWidget {
  const _GarageBlurredGlow({
    required this.left,
    required this.top,
    required this.size,
    required this.circleSize,
    required this.blurSigma,
    required this.color,
  });

  final double left;
  final double top;
  final double size;
  final double circleSize;
  final double blurSigma;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Center(
          child: SizedBox.square(
            dimension: circleSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
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
