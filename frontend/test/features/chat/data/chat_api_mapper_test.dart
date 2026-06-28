import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/chat/data/datasources/chat_api_datasource.dart';
import 'package:frontend/features/chat/domain/entities/chat_message.dart';

void main() {
  test('maps backend chat state response', () {
    final state = ChatApiMapper.stateFromJson({
      'sessionId': 'session-1',
      'quickQuestions': ['Vehicle status', 'What can break soon?'],
      'messages': [
        {
          'id': 'message-1',
          'role': 'ASSISTANT',
          'text': 'The assistant is ready.',
          'createdAt': '2026-06-12T10:00:00Z',
          'action': null,
        },
      ],
    });

    expect(state.sessionId, 'session-1');
    expect(state.quickQuestions, ['Vehicle status', 'What can break soon?']);
    expect(state.messages, hasLength(1));
    expect(state.messages.single.role, ChatMessageRole.assistant);
  });

  test('maps send message response with action payload', () {
    final result = ChatApiMapper.sendResultFromJson({
      'userMessage': {
        'id': 'user-1',
        'role': 'USER',
        'text': 'Заменил масло на 15000 км',
        'createdAt': '2026-06-12T10:00:00Z',
        'action': null,
      },
      'assistantMessage': {
        'id': 'assistant-1',
        'role': 'ASSISTANT',
        'text': 'Открою форму замены детали.',
        'createdAt': '2026-06-12T10:00:01Z',
        'action': {
          'type': 'OPEN_FORM',
          'form': 'PART_REPLACEMENT',
          'screen': null,
          'prefill': {'mileageKm': 15000},
        },
      },
    });

    expect(result.userMessage.role, ChatMessageRole.user);
    expect(result.assistantMessage.action?.type, 'OPEN_FORM');
    expect(result.assistantMessage.action?.form, 'PART_REPLACEMENT');
    expect(result.assistantMessage.action?.prefill['mileageKm'], 15000);
  });
}
