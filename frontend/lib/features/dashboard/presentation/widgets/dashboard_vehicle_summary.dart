import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_utils.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';

final class DashboardVehicleSummary extends StatelessWidget {
  const DashboardVehicleSummary({required this.vehicle, super.key});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _VehicleHero(vehicle: vehicle),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'MILEAGE',
                value: DashboardUtils.formatNumber(vehicle.currentMileageKm),
                suffix: 'km',
                subtitle: 'Current odometer',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _MetricCard(
                label: 'ENGINE',
                value: DashboardUtils.engineLabel(vehicle.engineType),
                subtitle: [
                  vehicle.year.toString(),
                  if (vehicle.color case final color?
                      when color.trim().isNotEmpty)
                    color.trim(),
                ].join(' • '),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _VinPlaceholderCard(),
      ],
    );
  }
}

final class _VehicleHero extends StatelessWidget {
  const _VehicleHero({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final photoUrl = vehicle.photoUrl?.trim();

    return Container(
      height: 252,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.border,
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
                colors: [Colors.transparent, Color(0xE610131A)],
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
          colors: [Color(0xFF102B3B), Color(0xFF131B31), Color(0xFF10131A)],
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/navigation/car.svg',
          width: 118,
          colorFilter: const ColorFilter.mode(
            AppColors.primaryLight,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

final class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    this.suffix,
  });

  final String label;
  final String value;
  final String subtitle;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: dashboardSectionLabelStyle(context)),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 25),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    suffix!,
                    style: dashboardSectionLabelStyle(context),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

final class _VinPlaceholderCard extends StatelessWidget {
  const _VinPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VIN NUMBER', style: dashboardSectionLabelStyle(context)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'VIN unavailable',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.copy_outlined, color: AppColors.textDisabled),
        ],
      ),
    );
  }
}
