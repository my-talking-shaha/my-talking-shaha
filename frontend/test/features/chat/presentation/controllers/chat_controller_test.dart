import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/providers/history_mutation_invalidation_provider.dart';
import 'package:frontend/features/chat/di/chat_providers.dart';
import 'package:frontend/features/chat/domain/entities/chat_message.dart';
import 'package:frontend/features/chat/domain/entities/chat_state.dart';
import 'package:frontend/features/chat/domain/entities/send_message_result.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

void main() {
  test(
    'chat-created event invalidates all vehicle history consumers',
    () async {
      String? invalidatedVehicleId;
      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(
            const _CreatedEventChatRepository(),
          ),
          historyMutationInvalidationProvider.overrideWithValue((vehicleId) {
            invalidatedVehicleId = vehicleId;
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(chatControllerProvider('vehicle-1').future);
      await container
          .read(chatControllerProvider('vehicle-1').notifier)
          .send('Add a trip');

      expect(invalidatedVehicleId, isNull);
      await Future<void>.delayed(Duration.zero);
      expect(invalidatedVehicleId, 'vehicle-1');
      expect(
        container.read(chatControllerProvider('vehicle-1')).value?.messages,
        hasLength(2),
      );
    },
  );
}

final class _CreatedEventChatRepository implements ChatRepository {
  const _CreatedEventChatRepository();

  @override
  Future<ChatState> getState(String vehicleId) async {
    return const ChatState(
      sessionId: 'session-1',
      quickQuestions: [],
      messages: [],
    );
  }

  @override
  Future<SendMessageResult> sendMessage({
    required String vehicleId,
    required String text,
  }) async {
    return SendMessageResult(
      userMessage: ChatMessage(
        id: 'user-1',
        role: ChatMessageRole.user,
        text: text,
        createdAt: DateTime(2026, 7, 17, 12),
      ),
      assistantMessage: ChatMessage(
        id: 'assistant-1',
        role: ChatMessageRole.assistant,
        text: 'Trip created',
        createdAt: DateTime(2026, 7, 17, 12, 1),
      ),
      hasCreatedEvent: true,
    );
  }
}
