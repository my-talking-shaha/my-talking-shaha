import 'package:frontend/features/chat/domain/entities/chat_message.dart';

final class ChatState {
  const ChatState({
    required this.sessionId,
    required this.quickQuestions,
    required this.messages,
  });

  final String sessionId;
  final List<String> quickQuestions;
  final List<ChatMessage> messages;
}
