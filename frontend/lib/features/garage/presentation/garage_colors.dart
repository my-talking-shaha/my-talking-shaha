import 'package:flutter/material.dart';

/// The complete color palette used by the garage presentation layer.
///
/// Values intentionally mirror the pre-refactor UI so moving widgets between
/// files cannot silently change the feature's appearance.
abstract final class GarageColors {
  static const background = Color(0xFF10131A);
  static const backgroundDark = Color(0xFF0E1118);
  static const formBackground = Color(0xFF0D111A);

  static const surface = Color(0xFF191A21);
  static const surfaceHighest = Color(0xFF232731);
  static const formField = Color(0xFF20242D);

  static const border = Color(0xFF2B303B);
  static const formBorder = Color(0xFF3B4252);

  static const primary = Color(0xFF2E5BFF);
  static const formPrimary = Color(0xFF315BFF);
  static const primaryLight = Color(0xFFB8C3FF);
  static const primaryPressed = Color(0xFF3F63C9);
  static const primarySoft = Color(0xFF141B30);

  static const textPrimary = Color(0xFFF4F7FF);
  static const textSecondary = Color(0xFF9AA3B2);
  static const hint = Color(0xFF6F7482);
  static const white = Color(0xFFFFFFFF);

  static const success = Color(0xFF00DCE5);
  static const error = Color(0xFFE85D75);
  static const swipeEdit = Color(0xFFDCA249);
  static const swipeDelete = Color(0xFFD4352F);
  static const transparent = Color(0x00000000);
}
