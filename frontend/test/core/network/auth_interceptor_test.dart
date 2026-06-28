import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/auth_interceptor.dart';

void main() {
  late FlutterSecureStoragePlatform originalPlatform;

  setUp(() {
    originalPlatform = FlutterSecureStoragePlatform.instance;
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform({
      'auth_token': 'jwt-access-token',
    });
  });

  tearDown(() {
    FlutterSecureStoragePlatform.instance = originalPlatform;
  });

  test('adds bearer token to protected requests', () async {
    final adapter = _CapturingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
      ..interceptors.add(AuthInterceptor())
      ..httpClientAdapter = adapter;

    await dio.get<void>('/vehicles');

    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer jwt-access-token',
    );
  });

  test('does not add bearer token to auth requests', () async {
    final adapter = _CapturingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
      ..interceptors.add(AuthInterceptor())
      ..httpClientAdapter = adapter;

    await dio.post<void>('/auth/login');

    expect(adapter.lastOptions?.headers['Authorization'], isNull);
  });
}

final class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}
