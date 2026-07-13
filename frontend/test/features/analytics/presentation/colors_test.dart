import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/analytics/presentation/colors.dart';

void main() {
  test('analytics palette preserves the design baseline', () {
    expect(AnalyticsColors.background.toARGB32(), 0xFF10131A);
    expect(AnalyticsColors.backgroundDark.toARGB32(), 0xFF0E1118);
    expect(AnalyticsColors.surface.toARGB32(), 0xFF191A21);
    expect(AnalyticsColors.surfaceHigh.toARGB32(), 0xFF1C1F25);
    expect(AnalyticsColors.border.toARGB32(), 0xFF2B303B);
    expect(AnalyticsColors.primaryLight.toARGB32(), 0xFFB8C3FF);
    expect(AnalyticsColors.textPrimary.toARGB32(), 0xFFF4F7FF);
    expect(AnalyticsColors.textSecondary.toARGB32(), 0xFF9AA3B2);
    expect(AnalyticsColors.textMuted.toARGB32(), 0xFF6F7788);
    expect(AnalyticsColors.success.toARGB32(), 0xFF00DCE5);
    expect(AnalyticsColors.warning.toARGB32(), 0xFFE8B950);
    expect(AnalyticsColors.transparent.toARGB32(), 0x00000000);
  });
}
