import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/chat/domain/entities/chat_message.dart';
import 'package:frontend/features/chat/presentation/utils/chat_formatters.dart';
import 'package:frontend/features/chat/presentation/utils/chat_message_presentation.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_action_pill.dart';
import 'package:frontend/features/chat/presentation/widgets/common/chat_assistant_mark.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.vehicleId, required this.message, super.key});

  final String vehicleId;
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatMessageRole.user;
    final text = isUser
        ? message.text
        : localizedBackendChatText(AppLocalizations.of(context), message.text);

    return LayoutBuilder(
      builder: (context, constraints) {
        final widthFactor = isUser ? 0.76 : 0.82;
        final maxBubbleWidth = (constraints.maxWidth * widthFactor).clamp(
          0.0,
          620.0,
        );
        final bubble = Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: IntrinsicWidth(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isUser
                      ? context.appColors.primary
                      : context.appColors.surfaceHigh,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadius.lg),
                    topRight: const Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(
                      isUser ? AppRadius.lg : AppSpacing.xs,
                    ),
                    bottomRight: Radius.circular(
                      isUser ? AppSpacing.xs : AppRadius.lg,
                    ),
                  ),
                  border: Border.all(
                    color: isUser
                        ? context.appColors.primaryPressed
                        : context.appColors.border,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isUser ? 18 : 17,
                    13,
                    isUser ? 18 : 17,
                    8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isUser
                              ? context.appColors.onPrimary
                              : context.appColors.textPrimary,
                          fontSize: 15,
                          height: 1.42,
                        ),
                      ),
                      if (!isUser && message.action != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        ChatActionPill(
                          vehicleId: vehicleId,
                          action: message.action!,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatChatTime(message.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isUser
                                    ? context.appColors.white.withValues(
                                        alpha: 0.7,
                                      )
                                    : context.appColors.textMuted,
                                height: 1,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                const ChatAssistantMark(size: 32, iconSize: 16),
                const SizedBox(width: AppSpacing.sm),
              ],
              bubble,
            ],
          ),
        );
      },
    );
  }
}
