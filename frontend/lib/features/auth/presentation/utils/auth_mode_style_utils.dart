import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/colors.dart';

abstract final class AuthModeStyleUtils {
  static BorderSide borderSide(Set<WidgetState> states) {
    final color = states.contains(WidgetState.selected)
        ? AuthColors.primary
        : AuthColors.border;
    return BorderSide(color: color);
  }

  static Color foregroundColor(Set<WidgetState> states) {
    return states.contains(WidgetState.selected)
        ? AuthColors.white
        : AuthColors.textSecondary;
  }

  static Color backgroundColor(Set<WidgetState> states) {
    return states.contains(WidgetState.selected)
        ? AuthColors.primary
        : AuthColors.surfaceHigh;
  }

  static ValueChanged<Set<T>> selectionHandler<T>(
    ValueChanged<T> onModeSelected,
  ) {
    return (selection) => onModeSelected(selection.first);
  }
}
