import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/presentation/utils/maintenance_forecast_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class ForecastSummary extends StatelessWidget {
  const ForecastSummary({required this.parts, super.key});

  final List<VehiclePart> parts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentCriticalParts = criticalParts(parts);
    final nextRemainingKm = nearestPositiveRemainingKm(parts);
    final headline = forecastHeadline(
      l10n,
      criticalParts: currentCriticalParts,
      nextPositiveRemainingKm: nextRemainingKm,
    );
    final caption = forecastCaption(
      l10n,
      criticalParts: currentCriticalParts,
      nextPositiveRemainingKm: nextRemainingKm,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/parts/maintenance.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                context.appColors.partsWarning,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                l10n.nextService,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.appColors.bodyText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          headline,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: context.appColors.bodyText,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.appColors.bodyTextMuted,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
