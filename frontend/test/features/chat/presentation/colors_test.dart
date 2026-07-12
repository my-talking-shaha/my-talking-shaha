import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/chat/presentation/colors.dart';

void main() {
  test('chat palette preserves bubble and action roles', () {
    expect(ChatColors.background, const Color(0xFF10131A));
    expect(ChatColors.surfaceHigh, const Color(0xFF1C1F25));
    expect(ChatColors.border, const Color(0xFF2B303B));
    expect(ChatColors.primary, const Color(0xFF2E5BFF));
    expect(ChatColors.primaryLight, const Color(0xFFB8C3FF));
    expect(ChatColors.primaryPressed, const Color(0xFF3F63C9));
    expect(ChatColors.textPrimary, const Color(0xFFF4F7FF));
    expect(ChatColors.textSecondary, const Color(0xFF9AA3B2));
    expect(ChatColors.textMuted, const Color(0xFF6F7788));
    expect(ChatColors.error, const Color(0xFFE85D75));
    expect(ChatColors.white, Colors.white);
    expect(ChatColors.black, Colors.black);
    expect(ChatColors.transparent, Colors.transparent);
  });
}
