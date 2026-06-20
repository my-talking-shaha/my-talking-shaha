import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _GarageEmptyBackground(),
          vehiclesState.when(
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
        ],
      ),
      bottomNavigationBar: const _GarageBottomNavigation(),
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
          title: const Text('Удалить авто?'),
          content: Text(
            '${vehicle.brand} ${vehicle.model} будет удалена из гаража.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
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
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
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
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _GarageBrandTitle(),
                Expanded(
                  child: Center(
                    child: GarageEmptyState(onAddVehicle: onAddVehicle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                  color: AppColors.primaryLight.withValues(alpha: 0.20),
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
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
        const _GarageBrandTitle(),
        const SizedBox(height: 42),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ТВОЙ ПАРК',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Гараж',
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
                tooltip: 'Добавить авто',
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

final class _GarageBrandTitle extends StatelessWidget {
  const _GarageBrandTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Моя Говорящая Шаха',
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        color: AppColors.primaryLight,
        fontSize: 31,
        fontWeight: FontWeight.w800,
        height: 1.08,
      ),
    );
  }
}

final class _GarageBottomNavigation extends StatelessWidget {
  const _GarageBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(color: AppColors.primarySoft.withValues(alpha: 0.7)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: const SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _GarageNavIcon(
                tooltip: 'Гараж',
                assetPath: 'assets/icons/navigation/car.svg',
                isActive: true,
              ),
              _GarageNavIcon(
                tooltip: 'Настройки',
                assetPath: 'assets/icons/navigation/settings.svg',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _GarageNavIcon extends StatelessWidget {
  const _GarageNavIcon({
    required this.tooltip,
    required this.assetPath,
    this.isActive = false,
  });

  final String tooltip;
  final String assetPath;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryLight : AppColors.textMuted;

    return Semantics(
      selected: isActive,
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: SizedBox.square(
          dimension: 56,
          child: Center(
            child: SvgPicture.asset(
              assetPath,
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        ),
      ),
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
            'Не удалось загрузить гараж',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}
