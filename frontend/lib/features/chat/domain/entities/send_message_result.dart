import 'package:frontend/features/chat/domain/entities/chat_message.dart';

final class SendMessageResult {
  const SendMessageResult({
    required this.userMessage,
    required this.assistantMessage,
    required this.hasCreatedEvent,
  });

  final ChatMessage userMessage;
  final ChatMessage assistantMessage;
  final bool hasCreatedEvent;
}
