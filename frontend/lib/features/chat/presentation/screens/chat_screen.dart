import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/chat/domain/entities/chat_action.dart';
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
          vehicleId: widget.vehicleId,
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
    required this.vehicleId,
    required this.state,
    required this.controller,
    required this.scrollController,
    required this.onSend,
  });

  final String vehicleId;
  final ChatScreenState state;
  final TextEditingController controller;
  final ScrollController scrollController;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final messages = _visibleMessages(state.messages);
    final quickQuestions = _quickQuestionsFromBackend(state.quickQuestions);

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
                    vehicleId: vehicleId,
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

  List<String> _quickQuestionsFromBackend(List<String> questions) {
    final result = <String>[];

    for (final question in questions) {
      final trimmedQuestion = question.trim();
      if (trimmedQuestion.isNotEmpty && !result.contains(trimmedQuestion)) {
        result.add(trimmedQuestion);
      }
    }

    return result;
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
    required this.vehicleId,
    required this.messages,
    required this.scrollController,
    required this.isSending,
  });

  final String vehicleId;
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

        return _ChatBubble(vehicleId: vehicleId, message: messages[index]);
      },
    );
  }
}

final class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.vehicleId, required this.message});

  final String vehicleId;
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatMessageRole.user;

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
                  padding: EdgeInsets.fromLTRB(
                    isUser ? AppSpacing.xl : AppSpacing.lg,
                    AppSpacing.lg,
                    isUser ? AppSpacing.xl : AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                      if (!isUser && message.action != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _ChatActionPill(
                          vehicleId: vehicleId,
                          action: message.action!,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _formatTime(message.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isUser
                                    ? AppColors.white.withValues(alpha: 0.7)
                                    : AppColors.textMuted,
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

final class _ChatActionPill extends StatelessWidget {
  const _ChatActionPill({required this.vehicleId, required this.action});

  final String vehicleId;
  final ChatAction action;

  @override
  Widget build(BuildContext context) {
    final destination = _destination();
    if (destination == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('chat_message_action'),
          onTap: () => context.go(destination),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon(), size: 16, color: AppColors.primaryLight),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _label(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _destination() {
    final type = action.type.toUpperCase();
    if (type == 'OPEN_SCREEN') {
      return switch (action.screen?.toUpperCase()) {
        'ANALYTICS' => '/vehicle/$vehicleId/analytics',
        'DASHBOARD' ||
        'MAINTENANCE_FORECAST' => '/vehicle/$vehicleId/dashboard',
        _ => null,
      };
    }

    if (type == 'OPEN_FORM') {
      final form = action.form?.toUpperCase();
      final routeType = switch (form) {
        'TRIP' => 'trip',
        'MAINTENANCE' || 'PART_REPLACEMENT' => 'maintenance',
        _ => 'fuel',
      };
      final query = <String, String>{'type': routeType};
      final mileageKm = action.prefill['mileageKm']?.toString();
      if (mileageKm != null && mileageKm.isNotEmpty) {
        query['mileageKm'] = mileageKm;
      }

      return Uri(
        path: '/vehicle/$vehicleId/history/add',
        queryParameters: query,
      ).toString();
    }

    return null;
  }

  String _label() {
    final type = action.type.toUpperCase();
    if (type == 'OPEN_SCREEN') {
      return switch (action.screen?.toUpperCase()) {
        'ANALYTICS' => 'Open analytics',
        'MAINTENANCE_FORECAST' => 'Open forecast',
        'DASHBOARD' => 'Open dashboard',
        _ => 'Open',
      };
    }

    return switch (action.form?.toUpperCase()) {
      'REFUEL' => 'Add refuel',
      'TRIP' => 'Add trip',
      'PART_REPLACEMENT' => 'Add part record',
      'MAINTENANCE' => 'Add maintenance',
      _ => 'Open form',
    };
  }

  IconData _icon() {
    final type = action.type.toUpperCase();
    if (type == 'OPEN_SCREEN') {
      return switch (action.screen?.toUpperCase()) {
        'ANALYTICS' => Icons.bar_chart_rounded,
        'MAINTENANCE_FORECAST' => Icons.build_circle_outlined,
        'DASHBOARD' => Icons.directions_car_filled_rounded,
        _ => Icons.open_in_new_rounded,
      };
    }

    return switch (action.form?.toUpperCase()) {
      'REFUEL' => Icons.local_gas_station_rounded,
      'TRIP' => Icons.route_rounded,
      'PART_REPLACEMENT' => Icons.build_circle_outlined,
      'MAINTENANCE' => Icons.handyman_rounded,
      _ => Icons.open_in_new_rounded,
    };
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

final class _TypingBubbleState extends State<_TypingBubble>
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
              child: Semantics(
                label: 'Assistant is thinking',
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ThinkingWaveText(progress: _controller.value),
                      ],
                    );
                  },
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
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(waveStart, 0),
          end: Alignment(waveStart + 1.1, 0),
          colors: const [
            AppColors.textSecondary,
            AppColors.primaryLight,
            AppColors.textPrimary,
            AppColors.primaryLight,
            AppColors.textSecondary,
          ],
          stops: const [0, 0.28, 0.5, 0.72, 1],
        ).createShader(bounds);
      },
      child: Text(
        'Shaha is thinking',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
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
