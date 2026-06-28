import 'package:frontend/features/chat/domain/entities/chat_message.dart';

final class SendMessageResult {
  const SendMessageResult({
    required this.userMessage,
    required this.assistantMessage,
  });

  final ChatMessage userMessage;
  final ChatMessage assistantMessage;
}
