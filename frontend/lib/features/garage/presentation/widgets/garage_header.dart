import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class GarageHeader extends StatelessWidget {
  const GarageHeader({required this.onAddVehicle, super.key});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.brandName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: context.appColors.primaryLight,
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
                    l10n.yourFleet,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.garage,
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
                tooltip: l10n.addVehicle,
                onPressed: onAddVehicle,
                style: IconButton.styleFrom(
                  backgroundColor: context.appColors.primary,
                  foregroundColor: context.appColors.white,
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
