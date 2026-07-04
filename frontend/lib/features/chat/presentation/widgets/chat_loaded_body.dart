import 'package:flutter/material.dart';
import 'package:frontend/features/chat/presentation/state/chat_screen_state.dart';
import 'package:frontend/features/chat/presentation/utils/chat_message_presentation.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_empty_state.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_message_list.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_suggestion_strip.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class ChatLoadedBody extends StatelessWidget {
  const ChatLoadedBody({
    required this.vehicleId,
    required this.state,
    required this.controller,
    required this.scrollController,
    required this.onSend,
    super.key,
  });

  final String vehicleId;
  final ChatScreenState state;
  final TextEditingController controller;
  final ScrollController scrollController;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messages = visibleChatMessages(state.messages);
    final quickQuestions = quickQuestionsFromBackend(
      l10n,
      state.quickQuestions,
    );
    final bottomSuggestions = bottomChatSuggestions(
      l10n: l10n,
      messages: messages,
      quickQuestions: quickQuestions,
      isSending: state.isSending,
    );

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? ChatEmptyState(
                    quickQuestions: quickQuestions,
                    onQuestionSelected: onSend,
                  )
                : ChatMessageList(
                    vehicleId: vehicleId,
                    messages: messages,
                    scrollController: scrollController,
                    isSending: state.isSending,
                  ),
          ),
          if (messages.isNotEmpty && bottomSuggestions.isNotEmpty)
            ChatSuggestionStrip(
              suggestions: bottomSuggestions,
              onSelected: onSend,
            ),
          ChatInputBar(
            controller: controller,
            isSending: state.isSending,
            onSend: onSend,
          ),
        ],
      ),
    );
  }
}
