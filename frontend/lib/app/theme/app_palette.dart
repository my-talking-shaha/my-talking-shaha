import 'package:flutter/material.dart';

@immutable
final class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.backgroundDark,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.border,
    required this.primary,
    required this.primaryLight,
    required this.primaryPressed,
    required this.primarySoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.success,
    required this.warning,
    required this.warningStrong,
    required this.partsWarning,
    required this.error,
    required this.info,
    required this.destructive,
    required this.formBackground,
    required this.formField,
    required this.formBorder,
    required this.formPrimary,
    required this.hint,
    required this.headerText,
    required this.bodyText,
    required this.progressTrack,
    required this.badgeBackground,
    required this.badgeBorder,
    required this.ok,
    required this.critical,
    required this.unknown,
    required this.heroOverlay,
    required this.heroGradientStart,
    required this.heroGradientMiddle,
    required this.heroGradientEnd,
    required this.fuelEventBackground,
    required this.maintenanceEventBackground,
  });

  static const dark = AppPalette(
    background: Color(0xFF10131A),
    backgroundDark: Color(0xFF0E1118),
    surface: Color(0xFF191A21),
    surfaceHigh: Color(0xFF1C1F25),
    surfaceHighest: Color(0xFF232731),
    border: Color(0xFF2B303B),
    primary: Color(0xFF2E5BFF),
    primaryLight: Color(0xFFB8C3FF),
    primaryPressed: Color(0xFF3F63C9),
    primarySoft: Color(0xFF141B30),
    textPrimary: Color(0xFFF4F7FF),
    textSecondary: Color(0xFF9AA3B2),
    textMuted: Color(0xFF6F7788),
    textDisabled: Color(0xFF4B5263),
    success: Color(0xFF00DCE5),
    warning: Color(0xFFE8B950),
    warningStrong: Color(0xFFDCA249),
    partsWarning: Color(0xFFFFD08A),
    error: Color(0xFFE85D75),
    info: Color(0xFF82A8BA),
    destructive: Color(0xFFD4352F),
    formBackground: Color(0xFF0D111A),
    formField: Color(0xFF20242D),
    formBorder: Color(0xFF3B4252),
    formPrimary: Color(0xFF315BFF),
    hint: Color(0xFF6F7482),
    headerText: Color(0xFFC4C5D9),
    bodyText: Color(0xFFE1E2EB),
    progressTrack: Color(0xFF343841),
    badgeBackground: Color(0xFF4A3A17),
    badgeBorder: Color(0xFF8B6500),
    ok: Color(0xFFADB5FF),
    critical: Color(0xFFFFAAA5),
    unknown: Color(0xFF8E90A2),
    heroOverlay: Color(0xE610131A),
    heroGradientStart: Color(0xFF102B3B),
    heroGradientMiddle: Color(0xFF131B31),
    heroGradientEnd: Color(0xFF10131A),
    fuelEventBackground: Color(0xFF30291F),
    maintenanceEventBackground: Color(0xFF123138),
  );

  static const light = AppPalette(
    background: Color(0xFFF1F4F9),
    backgroundDark: Color(0xFFE8EDF5),
    surface: Color(0xFFF9FAFD),
    surfaceHigh: Color(0xFFF3F6FA),
    surfaceHighest: Color(0xFFE6EBF3),
    border: Color(0xFFCBD3DF),
    primary: Color(0xFF3157D5),
    primaryLight: Color(0xFF4664C6),
    primaryPressed: Color(0xFF2647B8),
    primarySoft: Color(0xFFDDE5FF),
    textPrimary: Color(0xFF182033),
    textSecondary: Color(0xFF445067),
    textMuted: Color(0xFF5F6B80),
    textDisabled: Color(0xFF8B95A7),
    success: Color(0xFF007F89),
    warning: Color(0xFF9A6813),
    warningStrong: Color(0xFF8A5B0E),
    partsWarning: Color(0xFF8A5B0E),
    error: Color(0xFFC23B55),
    info: Color(0xFF356F88),
    destructive: Color(0xFFB72E2A),
    formBackground: Color(0xFFEDF1F7),
    formField: Color(0xFFF9FAFD),
    formBorder: Color(0xFFBFC9D7),
    formPrimary: Color(0xFF3157D5),
    hint: Color(0xFF68758A),
    headerText: Color(0xFF38445A),
    bodyText: Color(0xFF202A3D),
    progressTrack: Color(0xFFD5DCE7),
    badgeBackground: Color(0xFFFFF0CE),
    badgeBorder: Color(0xFFC48A20),
    ok: Color(0xFF4664C6),
    critical: Color(0xFFB72E2A),
    unknown: Color(0xFF68758A),
    heroOverlay: Color(0x66F1F4F9),
    heroGradientStart: Color(0xFFD9E9F1),
    heroGradientMiddle: Color(0xFFE1E7F5),
    heroGradientEnd: Color(0xFFF1F4F9),
    fuelEventBackground: Color(0xFFFFEBD0),
    maintenanceEventBackground: Color(0xFFD6EFF0),
  );

  final Color background;
  final Color backgroundDark;
  final Color surface;
  final Color surfaceHigh;
  final Color surfaceHighest;
  final Color border;
  final Color primary;
  final Color primaryLight;
  final Color primaryPressed;
  final Color primarySoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color success;
  final Color warning;
  final Color warningStrong;
  final Color partsWarning;
  final Color error;
  final Color info;
  final Color destructive;
  final Color formBackground;
  final Color formField;
  final Color formBorder;
  final Color formPrimary;
  final Color hint;
  final Color headerText;
  final Color bodyText;
  final Color progressTrack;
  final Color badgeBackground;
  final Color badgeBorder;
  final Color ok;
  final Color critical;
  final Color unknown;
  final Color heroOverlay;
  final Color heroGradientStart;
  final Color heroGradientMiddle;
  final Color heroGradientEnd;
  final Color fuelEventBackground;
  final Color maintenanceEventBackground;

  Color get cardBackground => surfaceHigh;
  Color get surfaceElevated => surfaceHighest;
  Color get unread => primaryLight;
  Color get accent => partsWarning;
  Color get headerTextMuted => primaryLight;
  Color get bodyTextMuted => headerText;
  Color get swipeEdit => warningStrong;
  Color get swipeDelete => destructive;
  Color get onPrimary => brightnessOn(primary);
  Color get white => Colors.white;
  Color get black => Colors.black;
  Color get transparent => Colors.transparent;

  static Color brightnessOn(Color color) {
    return color.computeLuminance() > 0.45
        ? const Color(0xFF182033)
        : Colors.white;
  }

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    return t < 0.5 || other == null ? this : other;
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get appColors {
    final theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.light
            ? AppPalette.light
            : AppPalette.dark);
  }
}
