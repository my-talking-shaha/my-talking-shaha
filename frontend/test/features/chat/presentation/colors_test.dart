import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/chat/presentation/colors.dart';

void main() {
  test('chat palette preserves the pre-refactor colors', () {
    expect(ChatColors.background.toARGB32(), 0xFF10131A);
    expect(ChatColors.surfaceHigh.toARGB32(), 0xFF1C1F25);
    expect(ChatColors.border.toARGB32(), 0xFF2B303B);
    expect(ChatColors.primary.toARGB32(), 0xFF2E5BFF);
    expect(ChatColors.primaryLight.toARGB32(), 0xFFB8C3FF);
    expect(ChatColors.primaryPressed.toARGB32(), 0xFF3F63C9);
    expect(ChatColors.textPrimary.toARGB32(), 0xFFF4F7FF);
    expect(ChatColors.textSecondary.toARGB32(), 0xFF9AA3B2);
    expect(ChatColors.textMuted.toARGB32(), 0xFF6F7788);
    expect(ChatColors.error.toARGB32(), 0xFFE85D75);
    expect(ChatColors.white.toARGB32(), 0xFFFFFFFF);
    expect(ChatColors.black.toARGB32(), 0xFF000000);
    expect(ChatColors.transparent.toARGB32(), 0x00000000);
  });
}
