import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';

abstract final class AuthModeStyleUtils {
  static BorderSide borderSide(BuildContext context, Set<WidgetState> states) {
    final color = states.contains(WidgetState.selected)
        ? context.appColors.primary
        : context.appColors.border;
    return BorderSide(color: color);
  }

  static Color foregroundColor(BuildContext context, Set<WidgetState> states) {
    return states.contains(WidgetState.selected)
        ? context.appColors.white
        : context.appColors.textSecondary;
  }

  static Color backgroundColor(BuildContext context, Set<WidgetState> states) {
    return states.contains(WidgetState.selected)
        ? context.appColors.primary
        : context.appColors.surfaceHigh;
  }

  static ValueChanged<Set<T>> selectionHandler<T>(
    ValueChanged<T> onModeSelected,
  ) {
    return (selection) => onModeSelected(selection.first);
  }
}
