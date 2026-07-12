import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/analytics/presentation/colors.dart';

void main() {
  test('analytics palette preserves surfaces, content and semantic accents',
      () {
    expect(AnalyticsColors.background, const Color(0xFF10131A));
    expect(AnalyticsColors.backgroundDark, const Color(0xFF0E1118));
    expect(AnalyticsColors.surface, const Color(0xFF191A21));
    expect(AnalyticsColors.surfaceHigh, const Color(0xFF1C1F25));
    expect(AnalyticsColors.border, const Color(0xFF2B303B));
    expect(AnalyticsColors.primaryLight, const Color(0xFFB8C3FF));
    expect(AnalyticsColors.textPrimary, const Color(0xFFF4F7FF));
    expect(AnalyticsColors.textSecondary, const Color(0xFF9AA3B2));
    expect(AnalyticsColors.textMuted, const Color(0xFF6F7788));
    expect(AnalyticsColors.success, const Color(0xFF00DCE5));
    expect(AnalyticsColors.warning, const Color(0xFFE8B950));
    expect(AnalyticsColors.transparent, Colors.transparent);
  });
}
