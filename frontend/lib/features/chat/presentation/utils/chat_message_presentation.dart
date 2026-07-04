import 'package:frontend/features/chat/domain/entities/chat_message.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

List<ChatMessage> visibleChatMessages(List<ChatMessage> messages) {
  return messages
      .where((message) => !_isInitialReadyMessage(message))
      .toList(growable: false);
}

List<String> quickQuestionsFromBackend(
  AppLocalizations l10n,
  List<String> questions,
) {
  final result = <String>[];

  for (final question in questions) {
    final trimmedQuestion = localizedBackendChatText(l10n, question.trim());
    if (trimmedQuestion.isNotEmpty && !result.contains(trimmedQuestion)) {
      result.add(trimmedQuestion);
    }
  }

  return result;
}

List<String> bottomChatSuggestions({
  required AppLocalizations l10n,
  required List<ChatMessage> messages,
  required List<String> quickQuestions,
  required bool isSending,
}) {
  if (isSending || messages.isEmpty) {
    return const [];
  }

  final latestMessage = messages.last;
  final fallbackSuggestions = _fallbackSuggestionsFor(l10n, latestMessage);
  if (fallbackSuggestions.isNotEmpty) {
    return fallbackSuggestions;
  }

  return quickQuestions;
}

bool _isInitialReadyMessage(ChatMessage message) {
  return message.role == ChatMessageRole.assistant &&
      message.text.trim().toLowerCase() == 'the assistant is ready.';
}

List<String> _fallbackSuggestionsFor(
  AppLocalizations l10n,
  ChatMessage message,
) {
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

  return [l10n.openAnalytics, l10n.quickQuestionVehicleStatus, l10n.addRefuel];
}

String localizedBackendChatText(AppLocalizations l10n, String text) {
  final trimmedText = text.trim();

  return switch (_normalizedChatText(trimmedText)) {
    'hi i am your car and i am ready to chat' => l10n.chatGreetingReady,
    'vehicle status' || 'состояние авто' => l10n.quickQuestionVehicleStatus,
    'what are my total expenses' ||
    'какие расходы за всё время' => l10n.quickQuestionTotalExpenses,
    'what can break soon' ||
    'что может сломаться скоро' => l10n.quickQuestionBreakSoon,
    _ => trimmedText,
  };
}

String _normalizedChatText(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[?!.,:;]+'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}
