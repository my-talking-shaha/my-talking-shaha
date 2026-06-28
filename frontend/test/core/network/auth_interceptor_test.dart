import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
      'auth_refresh_token': 'jwt-refresh-token',
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

  test(
    'refreshes an expired token and retries the protected request',
    () async {
      final adapter = _RefreshingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
        ..interceptors.add(AuthInterceptor(httpClientAdapter: adapter))
        ..httpClientAdapter = adapter;

      await dio.get<void>('/vehicles');

      expect(adapter.requestPaths, ['/vehicles', '/auth/refresh', '/vehicles']);
      expect(adapter.refreshedWithToken, 'jwt-refresh-token');
      expect(adapter.retryAuthorization, 'Bearer fresh-access-token');
      expect(
        await const FlutterSecureStorage().read(key: 'auth_token'),
        'fresh-access-token',
      );
      expect(
        await const FlutterSecureStorage().read(key: 'auth_refresh_token'),
        'fresh-refresh-token',
      );
    },
  );
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

final class _RefreshingAdapter implements HttpClientAdapter {
  final List<String> requestPaths = [];
  String? refreshedWithToken;
  String? retryAuthorization;
  bool _expiredTokenReturned = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestPaths.add(options.path);

    if (options.path == '/auth/refresh') {
      refreshedWithToken =
          (options.data as Map<String, dynamic>)['refreshToken']?.toString();
      return ResponseBody.fromString(
        '{"accessToken":"fresh-access-token","refreshToken":"fresh-refresh-token"}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    if (!_expiredTokenReturned) {
      _expiredTokenReturned = true;
      return ResponseBody.fromString(
        '{"code":"AUTHENTICATION_REQUIRED"}',
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    retryAuthorization = options.headers['Authorization']?.toString();
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}
