import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/parts/presentation/colors.dart';

void main() {
  test('parts palette preserves resource and forecast roles', () {
    expect(PartsColors.headerText, const Color(0xFFC4C5D9));
    expect(PartsColors.headerTextMuted, const Color(0xFFB8C3FF));
    expect(PartsColors.cardBackground, const Color(0xFF1C1F25));
    expect(PartsColors.bodyText, const Color(0xFFE1E2EB));
    expect(PartsColors.bodyTextMuted, const Color(0xFFC4C5D9));
    expect(PartsColors.progressTrack, const Color(0xFF343841));
    expect(PartsColors.badgeBackground, const Color(0xFF4A3A17));
    expect(PartsColors.badgeBorder, const Color(0xFF8B6500));
    expect(PartsColors.accent, const Color(0xFFFFD08A));
    expect(PartsColors.ok, const Color(0xFFADB5FF));
    expect(PartsColors.warning, const Color(0xFFFFD08A));
    expect(PartsColors.critical, const Color(0xFFFFAAA5));
    expect(PartsColors.unknown, const Color(0xFF8E90A2));
    expect(PartsColors.border, const Color(0xFF2B303B));
    expect(PartsColors.error, const Color(0xFFE85D75));
  });
}
