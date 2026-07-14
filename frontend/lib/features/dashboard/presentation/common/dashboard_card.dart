import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';

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
        color: context.appColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: context.appColors.border),
      ),
      child: child,
    );
  }
}
