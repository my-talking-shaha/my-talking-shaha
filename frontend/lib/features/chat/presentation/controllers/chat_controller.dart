import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:frontend/features/chat/domain/entities/chat_message.dart';
import 'package:frontend/features/chat/presentation/providers/chat_providers.dart';
import 'package:frontend/features/chat/presentation/state/chat_screen_state.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:frontend/features/history/presentation/providers/history_providers.dart';

final class ChatController extends AsyncNotifier<ChatScreenState> {
  ChatController(this.vehicleId);

  final String vehicleId;

  @override
  Future<ChatScreenState> build() async {
    final chatState = await ref.watch(chatRepositoryProvider).getState(vehicleId);

    return ChatScreenState(
      sessionId: chatState.sessionId,
      quickQuestions: chatState.quickQuestions,
      messages: chatState.messages,
    );
  }

  Future<void> reload() async {
    state = const AsyncLoading<ChatScreenState>();
    state = await AsyncValue.guard(() async {
      final chatState = await ref.read(chatRepositoryProvider).getState(vehicleId);

      return ChatScreenState(
        sessionId: chatState.sessionId,
        quickQuestions: chatState.quickQuestions,
        messages: chatState.messages,
      );
    });
  }

  Future<void> send(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final currentState = state.value;
    if (currentState == null || currentState.isSending) return;

    final localMessage = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      role: ChatMessageRole.user,
      text: trimmedText,
      createdAt: DateTime.now(),
    );

    state = AsyncData(
      currentState.copyWith(
        messages: [...currentState.messages, localMessage],
        isSending: true,
        clearError: true,
      ),
    );

    final result = await AsyncValue.guard(() {
      return ref
          .read(chatRepositoryProvider)
          .sendMessage(vehicleId: vehicleId, text: trimmedText);
    });

    result.when(
      data: (sendResult) {
        if (sendResult.hasCreatedEvent) {
          _refreshVehicleData();
        }
        final latestState = state.value ?? currentState;
        final messages = latestState.messages
            .where((message) => message.id != localMessage.id)
            .toList(growable: false);
        state = AsyncData(
          latestState.copyWith(
            messages: [
              ...messages,
              sendResult.userMessage,
              sendResult.assistantMessage,
            ],
            isSending: false,
            clearError: true,
          ),
        );
      },
      error: (error, stackTrace) {
        final latestState = state.value ?? currentState;
        state = AsyncData(
          latestState.copyWith(
            isSending: false,
            errorMessage:
                'Could not get a reply. Check the backend and try again.',
          ),
        );
      },
      loading: () {},
    );
  }

  void _refreshVehicleData() {
    ref.invalidate(historyEventsProvider(vehicleId));
    ref.invalidate(vehicleDashboardProvider(vehicleId));
    for (final period in AnalyticsPeriod.values) {
      ref.invalidate(analyticsSummaryProvider((
        vehicleId: vehicleId,
        period: period,
      )));
    }
  }
}
