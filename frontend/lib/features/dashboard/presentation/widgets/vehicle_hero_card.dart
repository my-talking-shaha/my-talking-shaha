import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/colors.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';

final class VehicleHeroCard extends StatelessWidget {
  const VehicleHeroCard({required this.vehicle, super.key});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final photoUrl = vehicle.photoUrl?.trim();

    return Container(
      height: 252,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: DashboardColors.border,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photoUrl != null && photoUrl.isNotEmpty)
            Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _VehicleHeroFallback(),
            )
          else
            const _VehicleHeroFallback(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DashboardColors.transparent,
                  DashboardColors.heroOverlay,
                ],
                stops: [0.44, 1],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.lg,
            child: Text(
              '${vehicle.brand} ${vehicle.model}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 25, height: 1.05),
            ),
          ),
        ],
      ),
    );
  }
}

final class _VehicleHeroFallback extends StatelessWidget {
  const _VehicleHeroFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashboardColors.heroGradientStart,
            DashboardColors.heroGradientMiddle,
            DashboardColors.heroGradientEnd,
          ],
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/navigation/car.svg',
          width: 118,
          colorFilter: const ColorFilter.mode(
            DashboardColors.primaryLight,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
