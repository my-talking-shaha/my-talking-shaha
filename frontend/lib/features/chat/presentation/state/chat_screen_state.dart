import 'package:frontend/features/chat/domain/entities/chat_message.dart';

final class ChatScreenState {
  const ChatScreenState({
    required this.sessionId,
    required this.quickQuestions,
    required this.messages,
    this.isSending = false,
    this.errorMessage,
  });

  final String sessionId;
  final List<String> quickQuestions;
  final List<ChatMessage> messages;
  final bool isSending;
  final String? errorMessage;

  ChatScreenState copyWith({
    String? sessionId,
    List<String>? quickQuestions,
    List<ChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatScreenState(
      sessionId: sessionId ?? this.sessionId,
      quickQuestions: quickQuestions ?? this.quickQuestions,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
