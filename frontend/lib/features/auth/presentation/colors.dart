import 'package:flutter/material.dart';

/// Exact color tokens used by the auth presentation.
///
/// These values intentionally mirror the pre-refactoring UI. Keep auth widgets
/// dependent on this palette so their colors can be audited in one place.
abstract final class AuthColors {
  static const background = Color(0xFF10131A);
  static const surface = Color(0xFF191A21);
  static const surfaceHigh = Color(0xFF1C1F25);
  static const surfaceHighest = Color(0xFF232731);

  static const border = Color(0xFF2B303B);
  static const formBorder = Color(0xFF3A4153);

  static const primary = Color(0xFF2E5BFF);
  static const primaryLight = Color(0xFFB8C3FF);

  static const textPrimary = Color(0xFFF4F7FF);
  static const textSecondary = Color(0xFF9AA3B2);
  static const textMuted = Color(0xFF6F7788);
  static const textDisabled = Color(0xFF4B5263);

  static const error = Color(0xFFE85D75);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}
