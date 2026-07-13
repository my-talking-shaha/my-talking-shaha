import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';

final class GarageMetricTile extends StatelessWidget {
  const GarageMetricTile({
    required this.iconPath,
    required this.label,
    required this.value,
    super.key,
  });

  final String iconPath;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: GarageColors.backgroundDark.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: GarageColors.border.withValues(alpha: 0.32),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 14, height: 14),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: GarageColors.textPrimary,
                fontSize: 10,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
