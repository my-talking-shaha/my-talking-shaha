import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class GarageErrorState extends StatelessWidget {
  const GarageErrorState({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: GarageColors.error, size: 40),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.couldNotLoadGarage,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
