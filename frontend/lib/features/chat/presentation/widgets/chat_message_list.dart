import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/chat/domain/entities/chat_message.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:frontend/features/chat/presentation/widgets/chat_typing_bubble.dart';

final class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    required this.vehicleId,
    required this.messages,
    required this.scrollController,
    required this.isSending,
    super.key,
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
        if (index == messages.length) return const ChatTypingBubble();
        return ChatBubble(vehicleId: vehicleId, message: messages[index]);
      },
    );
  }
}
