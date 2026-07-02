import 'package:dio/dio.dart';
import 'package:frontend/features/chat/data/datasources/chat_datasource.dart';
import 'package:frontend/features/chat/domain/entities/chat_action.dart';
import 'package:frontend/features/chat/domain/entities/chat_message.dart';
import 'package:frontend/features/chat/domain/entities/chat_state.dart';
import 'package:frontend/features/chat/domain/entities/send_message_result.dart';

final class ChatApiDatasource implements ChatDatasource {
  const ChatApiDatasource(this._dio);

  final Dio _dio;

  @override
  Future<ChatState> getState(String vehicleId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/vehicles/$vehicleId/chat',
    );

    return ChatApiMapper.stateFromJson(response.data ?? const {});
  }

  @override
  Future<SendMessageResult> sendMessage({
    required String vehicleId,
    required String text,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/vehicles/$vehicleId/chat/messages',
      data: {'text': text},
      options: Options(
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    return ChatApiMapper.sendResultFromJson(response.data ?? const {});
  }
}

abstract final class ChatApiMapper {
  static ChatState stateFromJson(Map<String, dynamic> json) {
    return ChatState(
      sessionId: _stringValue(json['sessionId']),
      quickQuestions: _stringListValue(json['quickQuestions']),
      messages: _messageListValue(json['messages']),
    );
  }

  static SendMessageResult sendResultFromJson(Map<String, dynamic> json) {
    return SendMessageResult(
      userMessage: messageFromJson(_mapValue(json['userMessage'])),
      assistantMessage: messageFromJson(_mapValue(json['assistantMessage'])),
      hasCreatedEvent: json['createdEvent'] is Map,
    );
  }

  static ChatMessage messageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _stringValue(json['id']),
      role: _roleValue(json['role']),
      text: _stringValue(json['text']),
      createdAt: _dateTimeValue(json['createdAt']),
      action: _actionValue(json['action']),
    );
  }

  static ChatAction? _actionValue(Object? value) {
    if (value is! Map) return null;

    final json = Map<String, dynamic>.from(value);
    final prefillValue = json['prefill'];
    return ChatAction(
      type: _stringValue(json['type']),
      form: _nullableStringValue(json['form']),
      screen: _nullableStringValue(json['screen']),
      prefill: prefillValue is Map
          ? Map<String, Object?>.from(prefillValue)
          : const {},
    );
  }

  static List<ChatMessage> _messageListValue(Object? value) {
    if (value is! List) return const [];

    return value
        .whereType<Map<String, dynamic>>()
        .map(messageFromJson)
        .toList(growable: false);
  }

  static List<String> _stringListValue(Object? value) {
    if (value is! List) return const [];

    return value
        .map((item) => item?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static ChatMessageRole _roleValue(Object? value) {
    return switch (value?.toString().toUpperCase()) {
      'USER' => ChatMessageRole.user,
      _ => ChatMessageRole.assistant,
    };
  }

  static DateTime _dateTimeValue(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed?.toLocal() ?? DateTime.now();
  }

  static Map<String, dynamic> _mapValue(Object? value) {
    return value is Map<String, dynamic> ? value : const {};
  }

  static String _stringValue(Object? value) {
    return value?.toString() ?? '';
  }

  static String? _nullableStringValue(Object? value) {
    final stringValue = value?.toString();
    return stringValue == null || stringValue.isEmpty ? null : stringValue;
  }
}
