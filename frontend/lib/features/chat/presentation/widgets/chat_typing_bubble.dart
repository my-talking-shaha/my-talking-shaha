import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/chat/presentation/widgets/common/chat_assistant_mark.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class ChatTypingBubble extends StatefulWidget {
  const ChatTypingBubble({super.key});

  @override
  State<ChatTypingBubble> createState() => _ChatTypingBubbleState();
}

final class _ChatTypingBubbleState extends State<ChatTypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ChatAssistantMark(size: 32, iconSize: 16),
          const SizedBox(width: AppSpacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.appColors.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.appColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Semantics(
                label: l10n.assistantThinking,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) =>
                      _ThinkingWaveText(progress: _controller.value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ThinkingWaveText extends StatelessWidget {
  const _ThinkingWaveText({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final waveStart = -1.4 + progress * 2.8;

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment(waveStart, 0),
        end: Alignment(waveStart + 1.1, 0),
        colors: [
          context.appColors.textSecondary,
          context.appColors.primaryLight,
          context.appColors.textPrimary,
          context.appColors.primaryLight,
          context.appColors.textSecondary,
        ],
        stops: const [0, 0.28, 0.5, 0.72, 1],
      ).createShader(bounds),
      child: Text(
        AppLocalizations.of(context).shahaThinking,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: context.appColors.textSecondary,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      ),
    );
  }
}
