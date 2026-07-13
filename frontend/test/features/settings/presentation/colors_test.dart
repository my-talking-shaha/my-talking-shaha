import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/settings/presentation/colors.dart';

void main() {
  test('settings palette preserves profile and control roles', () {
    expect(SettingsColors.background, const Color(0xFF10131A));
    expect(SettingsColors.surface, const Color(0xFF191A21));
    expect(SettingsColors.surfaceHighest, const Color(0xFF232731));
    expect(SettingsColors.border, const Color(0xFF2B303B));
    expect(SettingsColors.primary, const Color(0xFF2E5BFF));
    expect(SettingsColors.primaryLight, const Color(0xFFB8C3FF));
    expect(SettingsColors.textPrimary, const Color(0xFFF4F7FF));
    expect(SettingsColors.textSecondary, const Color(0xFF9AA3B2));
    expect(SettingsColors.textMuted, const Color(0xFF6F7788));
    expect(SettingsColors.textDisabled, const Color(0xFF4B5263));
    expect(SettingsColors.white, Colors.white);
    expect(SettingsColors.transparent, Colors.transparent);
  });
}
