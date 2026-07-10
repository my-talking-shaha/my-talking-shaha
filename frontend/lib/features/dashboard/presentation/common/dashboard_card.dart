import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/colors.dart';

final class DashboardCard extends StatelessWidget {
  const DashboardCard({
    required this.child,
    this.height,
    this.padding,
    super.key,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: DashboardColors.border),
      ),
      child: child,
    );
  }
}
