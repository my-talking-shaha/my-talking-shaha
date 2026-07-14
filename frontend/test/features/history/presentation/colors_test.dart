import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/presentation/colors.dart';

void main() {
  test('history palette preserves timeline and form roles', () {
    expect(HistoryColors.background, const Color(0xFF0E1118));
    expect(HistoryColors.surface, const Color(0xFF1C1F25));
    expect(HistoryColors.surfaceElevated, const Color(0xFF232731));
    expect(HistoryColors.border, const Color(0xFF2B303B));
    expect(HistoryColors.primary, const Color(0xFFB8C3FF));
    expect(HistoryColors.primarySoft, const Color(0xFF141B30));
    expect(HistoryColors.primaryPressed, const Color(0xFF3F63C9));
    expect(HistoryColors.onPrimary, const Color(0xFF002388));
    expect(HistoryColors.textPrimary, const Color(0xFFF4F7FF));
    expect(HistoryColors.textSecondary, const Color(0xFF9AA3B2));
    expect(HistoryColors.textMuted, const Color(0xFF6F7788));
    expect(HistoryColors.white, Colors.white);
    expect(HistoryColors.warning, const Color(0xFFDCA249));
    expect(HistoryColors.error, const Color(0xFFE85D75));
    expect(HistoryColors.destructive, const Color(0xFFD4352F));
    expect(HistoryColors.transparent, Colors.transparent);
  });
}
