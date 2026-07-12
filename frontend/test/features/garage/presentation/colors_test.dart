import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';

void main() {
  test('garage palette preserves cards, forms and swipe actions', () {
    expect(GarageColors.background, const Color(0xFF10131A));
    expect(GarageColors.backgroundDark, const Color(0xFF0E1118));
    expect(GarageColors.formBackground, const Color(0xFF0D111A));
    expect(GarageColors.surface, const Color(0xFF191A21));
    expect(GarageColors.surfaceHighest, const Color(0xFF232731));
    expect(GarageColors.formField, const Color(0xFF20242D));
    expect(GarageColors.border, const Color(0xFF2B303B));
    expect(GarageColors.formBorder, const Color(0xFF3B4252));
    expect(GarageColors.primary, const Color(0xFF2E5BFF));
    expect(GarageColors.formPrimary, const Color(0xFF315BFF));
    expect(GarageColors.primaryLight, const Color(0xFFB8C3FF));
    expect(GarageColors.primaryPressed, const Color(0xFF3F63C9));
    expect(GarageColors.primarySoft, const Color(0xFF141B30));
    expect(GarageColors.textPrimary, const Color(0xFFF4F7FF));
    expect(GarageColors.textSecondary, const Color(0xFF9AA3B2));
    expect(GarageColors.hint, const Color(0xFF6F7482));
    expect(GarageColors.white, Colors.white);
    expect(GarageColors.success, const Color(0xFF00DCE5));
    expect(GarageColors.error, const Color(0xFFE85D75));
    expect(GarageColors.swipeEdit, const Color(0xFFDCA249));
    expect(GarageColors.swipeDelete, const Color(0xFFD4352F));
    expect(GarageColors.transparent, Colors.transparent);
  });
}
