import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/chat/presentation/providers/chat_providers.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_loaded_body.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_states.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_title.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
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
          ..showSnackBar(
            SnackBar(content: Text(_localizedChatError(context, errorMessage))),
          );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/garage'),
          tooltip: l10n.openGarage,
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
        ),
        titleSpacing: 0,
        title: const ChatTitle(),
      ),
      body: chatState.when(
        data: (state) => ChatLoadedBody(
          vehicleId: widget.vehicleId,
          state: state,
          controller: _messageController,
          scrollController: _scrollController,
          onSend: _send,
        ),
        loading: () => const ChatWarmupState(),
        error: (error, stackTrace) => ChatLoadError(
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

String _localizedChatError(BuildContext context, String message) {
  final l10n = AppLocalizations.of(context);
  return switch (message) {
    'Could not get a reply. Check the backend and try again.' =>
      l10n.couldNotGetReply,
    _ => message,
  };
}
