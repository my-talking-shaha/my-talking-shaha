import 'package:frontend/features/chat/data/datasources/chat_datasource.dart';
import 'package:frontend/features/chat/domain/entities/chat_state.dart';
import 'package:frontend/features/chat/domain/entities/send_message_result.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

final class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._datasource);

  final ChatDatasource _datasource;

  @override
  Future<ChatState> getState(String vehicleId) {
    return _datasource.getState(vehicleId);
  }

  @override
  Future<SendMessageResult> sendMessage({
    required String vehicleId,
    required String text,
  }) {
    return _datasource.sendMessage(vehicleId: vehicleId, text: text);
  }
}
