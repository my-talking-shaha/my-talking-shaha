import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class GarageEmptyState extends StatelessWidget {
  const GarageEmptyState({required this.onAddVehicle, super.key});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.garage_outlined,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.garageEmpty,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.garageEmptyCompactDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAddVehicle,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addCar),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
