import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';

void main() {
  test('garage palette preserves the pre-refactor color values', () {
    expect(GarageColors.background.toARGB32(), 0xFF10131A);
    expect(GarageColors.backgroundDark.toARGB32(), 0xFF0E1118);
    expect(GarageColors.formBackground.toARGB32(), 0xFF0D111A);
    expect(GarageColors.surface.toARGB32(), 0xFF191A21);
    expect(GarageColors.surfaceHighest.toARGB32(), 0xFF232731);
    expect(GarageColors.formField.toARGB32(), 0xFF20242D);
    expect(GarageColors.border.toARGB32(), 0xFF2B303B);
    expect(GarageColors.formBorder.toARGB32(), 0xFF3B4252);
    expect(GarageColors.primary.toARGB32(), 0xFF2E5BFF);
    expect(GarageColors.formPrimary.toARGB32(), 0xFF315BFF);
    expect(GarageColors.primaryLight.toARGB32(), 0xFFB8C3FF);
    expect(GarageColors.primaryPressed.toARGB32(), 0xFF3F63C9);
    expect(GarageColors.primarySoft.toARGB32(), 0xFF141B30);
    expect(GarageColors.textPrimary.toARGB32(), 0xFFF4F7FF);
    expect(GarageColors.textSecondary.toARGB32(), 0xFF9AA3B2);
    expect(GarageColors.hint.toARGB32(), 0xFF6F7482);
    expect(GarageColors.white.toARGB32(), 0xFFFFFFFF);
    expect(GarageColors.success.toARGB32(), 0xFF00DCE5);
    expect(GarageColors.error.toARGB32(), 0xFFE85D75);
    expect(GarageColors.swipeEdit.toARGB32(), 0xFFDCA249);
    expect(GarageColors.swipeDelete.toARGB32(), 0xFFD4352F);
    expect(GarageColors.transparent.toARGB32(), 0x00000000);
  });
}
