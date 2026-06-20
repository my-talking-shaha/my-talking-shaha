import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class GarageEmptyState extends StatelessWidget {
  const GarageEmptyState({required this.onAddVehicle, super.key});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showIcon =
            !constraints.hasBoundedHeight || constraints.maxHeight >= 360;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showIcon) ...[
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.garage_outlined,
                        color: AppColors.primaryLight,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  Text(
                    'В гараже пока пусто',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Добавьте свой первый автомобиль, чтобы создать его цифровой двойник',
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
                      label: const Text('Добавить авто'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
