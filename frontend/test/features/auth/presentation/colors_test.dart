import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/presentation/colors.dart';

void main() {
  test('auth palette preserves form and interaction roles', () {
    expect(AuthColors.background, const Color(0xFF10131A));
    expect(AuthColors.surface, const Color(0xFF191A21));
    expect(AuthColors.surfaceHigh, const Color(0xFF1C1F25));
    expect(AuthColors.surfaceHighest, const Color(0xFF232731));
    expect(AuthColors.border, const Color(0xFF2B303B));
    expect(AuthColors.formBorder, const Color(0xFF3A4153));
    expect(AuthColors.primary, const Color(0xFF2E5BFF));
    expect(AuthColors.primaryLight, const Color(0xFFB8C3FF));
    expect(AuthColors.textPrimary, const Color(0xFFF4F7FF));
    expect(AuthColors.textSecondary, const Color(0xFF9AA3B2));
    expect(AuthColors.textMuted, const Color(0xFF6F7788));
    expect(AuthColors.textDisabled, const Color(0xFF4B5263));
    expect(AuthColors.error, const Color(0xFFE85D75));
    expect(AuthColors.white, Colors.white);
    expect(AuthColors.black, Colors.black);
  });
}
