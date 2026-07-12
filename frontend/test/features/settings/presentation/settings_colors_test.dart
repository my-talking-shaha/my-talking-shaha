import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/settings/presentation/colors.dart';

void main() {
  test('settings palette preserves the design baseline', () {
    expect(SettingsColors.background.toARGB32(), 0xFF10131A);
    expect(SettingsColors.surface.toARGB32(), 0xFF191A21);
    expect(SettingsColors.surfaceHighest.toARGB32(), 0xFF232731);
    expect(SettingsColors.border.toARGB32(), 0xFF2B303B);
    expect(SettingsColors.primary.toARGB32(), 0xFF2E5BFF);
    expect(SettingsColors.primaryLight.toARGB32(), 0xFFB8C3FF);
    expect(SettingsColors.textPrimary.toARGB32(), 0xFFF4F7FF);
    expect(SettingsColors.textSecondary.toARGB32(), 0xFF9AA3B2);
    expect(SettingsColors.textMuted.toARGB32(), 0xFF6F7788);
    expect(SettingsColors.textDisabled.toARGB32(), 0xFF4B5263);
    expect(SettingsColors.white.toARGB32(), 0xFFFFFFFF);
    expect(SettingsColors.transparent.toARGB32(), 0x00000000);
  });
}
