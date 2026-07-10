import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class GarageEmptyState extends StatelessWidget {
  const GarageEmptyState({required this.onAddVehicle, super.key});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                l10n.brandName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: GarageColors.primaryLight,
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
                        l10n.garageEmpty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.garageEmptyDescription,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: GarageColors.textSecondary,
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
                          label: Text(l10n.addVehicle),
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
        color: GarageColors.background,
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
                  color: GarageColors.primaryLight.withValues(alpha: 0.20),
                ),
                _GarageBlurredGlow(
                  left: dx + (94 * scale),
                  top: 287 * scale,
                  size: 496 * scale,
                  circleSize: 256 * scale,
                  blurSigma: 60 * scale,
                  color: GarageColors.success.withValues(alpha: 0.20),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        GarageColors.background.withValues(alpha: 0),
                        GarageColors.background.withValues(alpha: 0.34),
                        GarageColors.background.withValues(alpha: 0.64),
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
