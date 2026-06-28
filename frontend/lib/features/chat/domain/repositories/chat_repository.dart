import 'package:frontend/features/chat/domain/entities/chat_state.dart';
import 'package:frontend/features/chat/domain/entities/send_message_result.dart';

abstract interface class ChatRepository {
  Future<ChatState> getState(String vehicleId);

  Future<SendMessageResult> sendMessage({
    required String vehicleId,
    required String text,
  });
}
