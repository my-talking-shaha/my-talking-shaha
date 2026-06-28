import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/chat/domain/entities/chat_message.dart';
import 'package:frontend/features/chat/presentation/providers/chat_providers.dart';
import 'package:frontend/features/chat/presentation/state/chat_screen_state.dart';
import 'package:go_router/go_router.dart';

final class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

final class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = chatControllerProvider(widget.vehicleId);
    final chatState = ref.watch(provider);

    ref.listen(provider, (previous, next) {
      final previousCount = previous?.value?.messages.length ?? 0;
      final nextCount = next.value?.messages.length ?? 0;
      if (nextCount > previousCount) {
        _scrollToLatest();
      }

      final errorMessage = next.value?.errorMessage;
      if (errorMessage != null && errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/garage'),
          tooltip: 'Open garage',
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
        ),
        titleSpacing: 0,
        title: const _ChatTitle(),
      ),
      body: chatState.when(
        data: (state) => _ChatLoadedBody(
          state: state,
          controller: _messageController,
          scrollController: _scrollController,
          onSend: _send,
        ),
        loading: () => const _ChatWarmupState(),
        error: (error, stackTrace) => _ChatLoadError(
          onRetry: () => unawaited(ref.read(provider.notifier).reload()),
        ),
      ),
    );
  }

  void _send(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    _messageController.clear();
    unawaited(
      ref
          .read(chatControllerProvider(widget.vehicleId).notifier)
          .send(trimmedText),
    );
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      unawaited(
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }
}

final class _ChatLoadedBody extends StatelessWidget {
  const _ChatLoadedBody({
    required this.state,
    required this.controller,
    required this.scrollController,
    required this.onSend,
  });

  final ChatScreenState state;
  final TextEditingController controller;
  final ScrollController scrollController;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final messages = _visibleMessages(state.messages);
    final quickQuestions = _englishQuickQuestions(state.quickQuestions);

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _ChatEmptyState(
                    quickQuestions: quickQuestions,
                    onQuestionSelected: onSend,
                  )
                : _MessageList(
                    messages: messages,
                    scrollController: scrollController,
                    isSending: state.isSending,
                  ),
          ),
          if (messages.isNotEmpty && quickQuestions.isNotEmpty)
            _QuickQuestionStrip(
              questions: quickQuestions,
              onQuestionSelected: onSend,
            ),
          _ChatInputBar(
            controller: controller,
            isSending: state.isSending,
            onSend: onSend,
          ),
        ],
      ),
    );
  }

  List<ChatMessage> _visibleMessages(List<ChatMessage> messages) {
    return messages
        .where((message) => !_isInitialReadyMessage(message))
        .toList(growable: false);
  }

  bool _isInitialReadyMessage(ChatMessage message) {
    return message.role == ChatMessageRole.assistant &&
        message.text.trim().toLowerCase() == 'the assistant is ready.';
  }

  List<String> _englishQuickQuestions(List<String> questions) {
    final result = <String>[];

    for (final question in questions) {
      final translated = _translateQuickQuestion(question);
      if (translated.isNotEmpty && !result.contains(translated)) {
        result.add(translated);
      }
    }

    return result;
  }

  String _translateQuickQuestion(String question) {
    final normalized = question.trim().toLowerCase();
    return switch (normalized) {
      'состояние авто' => 'Vehicle status',
      'какие расходы за всё время?' => 'What are my total expenses?',
      'что может сломаться скоро?' => 'What can break soon?',
      'когда то?' || 'когда то' => 'When is the next service?',
      'добавить заправку' => 'Add refuel',
      'записать ремонт' => 'Log repair',
      _ => question.trim(),
    };
  }
}

final class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({
    required this.quickQuestions,
    required this.onQuestionSelected,
  });

  final List<String> quickQuestions;
  final ValueChanged<String> onQuestionSelected;

  @override
  Widget build(BuildContext context) {
    final questions = quickQuestions.isEmpty
        ? const [
            'Vehicle status',
            'When should I change oil?',
            'What can break soon?',
          ]
        : quickQuestions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxxl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      children: [
        const SizedBox(height: 72),
        const _AssistantMark(size: 84, iconSize: 38),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Shaha is online',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ask about vehicle condition, expenses, or maintenance.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        ...questions.map(
          (question) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _QuickQuestionTile(
              question: question,
              onTap: () => onQuestionSelected(question),
            ),
          ),
        ),
      ],
    );
  }
}

final class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.scrollController,
    required this.isSending,
  });

  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      itemCount: messages.length + (isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const _TypingBubble();
        }

        return _ChatBubble(message: messages[index]);
      },
    );
  }
}

final class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatMessageRole.user;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBubbleWidth = constraints.maxWidth * 0.78;
        final bubble = Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surfaceHigh,
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
                  color: isUser ? AppColors.primaryPressed : AppColors.border,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatTime(message.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUser
                              ? AppColors.primaryLight
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
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
                const _AssistantMark(size: 32, iconSize: 16),
                const SizedBox(width: AppSpacing.sm),
              ],
              bubble,
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

final class _QuickQuestionStrip extends StatelessWidget {
  const _QuickQuestionStrip({
    required this.questions,
    required this.onQuestionSelected,
  });

  final List<String> questions;
  final ValueChanged<String> onQuestionSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          scrollDirection: Axis.horizontal,
          itemCount: questions.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final question = questions[index];
            return ActionChip(
              onPressed: () => onQuestionSelected(question),
              label: Text(question),
              backgroundColor: AppColors.surfaceHigh,
              side: const BorderSide(color: AppColors.border),
              labelStyle: Theme.of(context).textTheme.labelMedium,
              shape: const StadiumBorder(),
            );
          },
        ),
      ),
    );
  }
}

final class _QuickQuestionTile extends StatelessWidget {
  const _QuickQuestionTile({required this.question, required this.onTap});

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(question, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}

final class _ChatInputBar extends StatefulWidget {
  const _ChatInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onSend;

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

final class _ChatInputBarState extends State<_ChatInputBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;

    oldWidget.controller.removeListener(_onTextChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend =
        widget.controller.text.trim().isNotEmpty && !widget.isSending;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.24),
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
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: widget.controller,
                  enabled: !widget.isSending,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: canSend ? widget.onSend : null,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox.square(
              dimension: 48,
              child: IconButton.filled(
                onPressed: canSend
                    ? () => widget.onSend(widget.controller.text)
                    : null,
                icon: widget.isSending
                    ? const Icon(Icons.smart_toy_rounded)
                    : const Icon(Icons.send_rounded),
                tooltip: 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTextChanged() {
    setState(() {});
  }
}

final class _ChatTitle extends StatelessWidget {
  const _ChatTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _AssistantMark(size: 36, iconSize: 18),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chat with Shaha',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Vehicle AI assistant',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

final class _TypingBubbleState extends State<_TypingBubble> {
  late final Timer _timer;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 360), (_) {
      setState(() {
        _dotCount = _dotCount == 3 ? 1 : _dotCount + 1;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.'.padRight(_dotCount, '.');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _AssistantMark(size: 32, iconSize: 16),
          const SizedBox(width: AppSpacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        dots,
                        key: ValueKey(dots),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.primaryLight),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Shaha is thinking',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ChatWarmupState extends StatelessWidget {
  const _ChatWarmupState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AssistantMark(size: 72, iconSize: 32),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Connecting to Shaha',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Preparing history and quick questions.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

final class _AssistantMark extends StatelessWidget {
  const _AssistantMark({required this.size, required this.iconSize});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: size * 0.28,
              spreadRadius: size * 0.08,
            ),
          ],
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          Icons.smart_toy_rounded,
          color: AppColors.white,
          size: iconSize,
        ),
      ),
    );
  }
}

final class _ChatLoadError extends StatelessWidget {
  const _ChatLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 42,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Chat did not load',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Check the connection and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
