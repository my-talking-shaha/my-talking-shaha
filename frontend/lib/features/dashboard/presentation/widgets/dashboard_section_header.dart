import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: dashboardSectionLabelStyle(context)),
        ),
        ?trailing,
      ],
    );
  }
}

TextStyle? dashboardSectionLabelStyle(BuildContext context) {
  return Theme.of(context).textTheme.labelMedium?.copyWith(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
}
