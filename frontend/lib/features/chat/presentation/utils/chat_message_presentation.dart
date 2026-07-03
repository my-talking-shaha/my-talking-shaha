import 'package:frontend/features/chat/domain/entities/chat_message.dart';

List<ChatMessage> visibleChatMessages(List<ChatMessage> messages) {
  return messages
      .where((message) => !_isInitialReadyMessage(message))
      .toList(growable: false);
}

List<String> quickQuestionsFromBackend(List<String> questions) {
  final result = <String>[];

  for (final question in questions) {
    final trimmedQuestion = question.trim();
    if (trimmedQuestion.isNotEmpty && !result.contains(trimmedQuestion)) {
      result.add(trimmedQuestion);
    }
  }

  return result;
}

List<String> bottomChatSuggestions({
  required List<ChatMessage> messages,
  required List<String> quickQuestions,
  required bool isSending,
}) {
  if (isSending || messages.isEmpty) {
    return const [];
  }

  final latestMessage = messages.last;
  final fallbackSuggestions = _fallbackSuggestionsFor(latestMessage);
  if (fallbackSuggestions.isNotEmpty) {
    return fallbackSuggestions;
  }

  return quickQuestions;
}

bool _isInitialReadyMessage(ChatMessage message) {
  return message.role == ChatMessageRole.assistant &&
      message.text.trim().toLowerCase() == 'the assistant is ready.';
}

List<String> _fallbackSuggestionsFor(ChatMessage message) {
  if (message.role == ChatMessageRole.user || message.action != null) {
    return const [];
  }

  final text = message.text.trim();
  final normalized = text.toLowerCase();
  final shouldSuggest =
      normalized.contains('did not fully understand') ||
      normalized.contains('you may have meant') ||
      normalized.contains('не до конца понял') ||
      normalized.contains('возможно, вы хотели');
  if (!shouldSuggest) {
    return const [];
  }

  return _isRussian(text)
      ? const ['Показать аналитику', 'Состояние авто', 'Добавить заправку']
      : const ['Show analytics', 'Vehicle status', 'Add refuel'];
}

bool _isRussian(String text) {
  return text.runes.any((rune) => rune >= 0x0400 && rune <= 0x04FF);
}
