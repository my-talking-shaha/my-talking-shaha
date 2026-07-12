import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/chat/data/datasources/chat_api_datasource.dart';
import 'package:frontend/features/chat/data/datasources/chat_datasource.dart';
import 'package:frontend/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:frontend/features/chat/presentation/controllers/chat_controller.dart';
import 'package:frontend/features/chat/presentation/state/chat_screen_state.dart';

final chatApiDatasourceProvider = Provider<ChatApiDatasource>((ref) {
  return ChatApiDatasource(ref.watch(dioProvider));
});

final chatDatasourceProvider = Provider<ChatDatasource>((ref) {
  return ref.watch(chatApiDatasourceProvider);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(chatDatasourceProvider));
});

final chatControllerProvider =
    AsyncNotifierProvider.family<ChatController, ChatScreenState, String>(
      ChatController.new,
      retry: (_, _) => null,
    );
