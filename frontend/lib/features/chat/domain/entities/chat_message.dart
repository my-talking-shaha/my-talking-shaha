import 'package:frontend/features/chat/domain/entities/chat_action.dart';

enum ChatMessageRole { user, assistant }

final class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.action,
  });

  final String id;
  final ChatMessageRole role;
  final String text;
  final DateTime createdAt;
  final ChatAction? action;
}
