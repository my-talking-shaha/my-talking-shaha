import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';

abstract final class DashboardTextStyleUtils {
  static TextStyle? sectionLabel(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium?.copyWith(
      color: context.appColors.textSecondary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    );
  }
}
