import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
    super.key,
  });

  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final canSend = value.text.trim().isNotEmpty && !isSending;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.appColors.background,
            boxShadow: [
              BoxShadow(
                color: context.appColors.black.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.appColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: TextField(
                      controller: controller,
                      enabled: !isSending,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: canSend ? onSend : null,
                      decoration: InputDecoration(
                        hintText: l10n.message,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox.square(
                  dimension: 44,
                  child: IconButton.filled(
                    onPressed: canSend ? () => onSend(controller.text) : null,
                    icon: const Icon(Icons.arrow_upward),
                    tooltip: l10n.sendMessage,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
