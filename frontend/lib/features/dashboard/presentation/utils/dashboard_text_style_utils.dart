import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/colors.dart';

abstract final class DashboardTextStyleUtils {
  static TextStyle? sectionLabel(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium?.copyWith(
      color: DashboardColors.textSecondary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    );
  }
}
