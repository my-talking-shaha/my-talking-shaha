import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/dashboard/presentation/colors.dart';

void main() {
  test('dashboard palette preserves shared and hero-specific roles', () {
    expect(DashboardColors.background, const Color(0xFF10131A));
    expect(DashboardColors.primary, const Color(0xFF2E5BFF));
    expect(DashboardColors.primaryLight, const Color(0xFFB8C3FF));
    expect(DashboardColors.surface, const Color(0xFF1C1F25));
    expect(DashboardColors.surfaceHighest, const Color(0xFF232731));
    expect(DashboardColors.border, const Color(0xFF2B303B));
    expect(DashboardColors.textPrimary, const Color(0xFFF4F7FF));
    expect(DashboardColors.textSecondary, const Color(0xFF9AA3B2));
    expect(DashboardColors.textMuted, const Color(0xFF6F7788));
    expect(DashboardColors.textDisabled, const Color(0xFF4B5263));
    expect(DashboardColors.success, const Color(0xFF00DCE5));
    expect(DashboardColors.warning, const Color(0xFFE8B950));
    expect(DashboardColors.heroOverlay, const Color(0xE610131A));
    expect(DashboardColors.heroGradientStart, const Color(0xFF102B3B));
    expect(DashboardColors.heroGradientMiddle, const Color(0xFF131B31));
    expect(DashboardColors.heroGradientEnd, const Color(0xFF10131A));
    expect(DashboardColors.fuelEventBackground, const Color(0xFF30291F));
    expect(
      DashboardColors.maintenanceEventBackground,
      const Color(0xFF123138),
    );
    expect(DashboardColors.transparent, Colors.transparent);
  });
}
