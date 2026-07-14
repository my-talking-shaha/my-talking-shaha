import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notifications/presentation/colors.dart';

void main() {
  test('notifications palette preserves category and content roles', () {
    expect(NotificationsColors.background, const Color(0xFF10131A));
    expect(NotificationsColors.surface, const Color(0xFF191A21));
    expect(NotificationsColors.border, const Color(0xFF2B303B));
    expect(NotificationsColors.divider, const Color(0xFF252A33));
    expect(NotificationsColors.textPrimary, const Color(0xFFF4F7FF));
    expect(NotificationsColors.textSecondary, const Color(0xFF9AA3B2));
    expect(NotificationsColors.textMuted, const Color(0xFF6F7788));
    expect(NotificationsColors.unread, const Color(0xFFB8C3FF));
    expect(NotificationsColors.warning, const Color(0xFFE8B950));
    expect(NotificationsColors.error, const Color(0xFFE85D75));
    expect(NotificationsColors.info, const Color(0xFF82A8BA));
  });
}
