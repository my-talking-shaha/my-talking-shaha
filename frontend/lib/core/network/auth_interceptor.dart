import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
    SharedPreferencesAsync? sharedPreferences,
    HttpClientAdapter? httpClientAdapter,
  }) : _secureStorage = secureStorage,
       _sharedPreferences = sharedPreferences,
       _httpClientAdapter = httpClientAdapter;

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _loginKey = 'auth_login';
  static const _fullNameKey = 'auth_full_name';
  static const _retriedAfterRefreshKey = 'retried_after_token_refresh';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferencesAsync? _sharedPreferences;
  final HttpClientAdapter? _httpClientAdapter;
  Future<_TokenPair?>? _refreshFuture;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAuthRequest(options.path)) {
      handler.next(options);
      return;
    }

    final token = await _readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final statusCode = err.response?.statusCode;
    final canRefresh =
        statusCode == 401 &&
        !_isAuthRequest(request.path) &&
        request.extra[_retriedAfterRefreshKey] != true;

    if (!canRefresh) {
      handler.next(err);
      return;
    }

    try {
      final tokenPair = await _refreshTokens(request);
      if (tokenPair == null) {
        handler.next(err);
        return;
      }

      final retryHeaders = Map<String, dynamic>.of(request.headers)
        ..['Authorization'] = 'Bearer ${tokenPair.accessToken}';
      final retryOptions = request.copyWith(
        headers: retryHeaders,
        extra: {...request.extra, _retriedAfterRefreshKey: true},
      );
      final retryDio = _createDio();
      final retryResponse = await retryDio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _clearSession();
      handler.next(err);
    }
  }

  Future<String?> _readToken() {
    if (kIsWeb) {
      return (_sharedPreferences ?? SharedPreferencesAsync()).getString(
        _tokenKey,
      );
    }

    return _secureStorage.read(key: _tokenKey);
  }

  Future<_TokenPair?> _refreshTokens(RequestOptions request) {
    final pendingRefresh = _refreshFuture;
    if (pendingRefresh != null) {
      return pendingRefresh;
    }

    final refreshFuture = _doRefreshTokens(request).whenComplete(() {
      _refreshFuture = null;
    });
    _refreshFuture = refreshFuture;
    return refreshFuture;
  }

  Future<_TokenPair?> _doRefreshTokens(RequestOptions request) async {
    final refreshToken = await _readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final response =
        await _createDio(
          BaseOptions(
            baseUrl: request.baseUrl,
            connectTimeout: request.connectTimeout,
            receiveTimeout: request.receiveTimeout,
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
        ).post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

    final data = response.data ?? const {};
    final tokenPair = _TokenPair(
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
    );
    if (tokenPair.accessToken.isEmpty || tokenPair.refreshToken.isEmpty) {
      return null;
    }

    await _saveTokenPair(tokenPair);
    return tokenPair;
  }

  Future<String?> _readRefreshToken() {
    if (kIsWeb) {
      return (_sharedPreferences ?? SharedPreferencesAsync()).getString(
        _refreshTokenKey,
      );
    }

    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> _saveTokenPair(_TokenPair tokenPair) async {
    if (kIsWeb) {
      final preferences = _sharedPreferences ?? SharedPreferencesAsync();
      await preferences.setString(_tokenKey, tokenPair.accessToken);
      await preferences.setString(_refreshTokenKey, tokenPair.refreshToken);
      return;
    }

    await _secureStorage.write(key: _tokenKey, value: tokenPair.accessToken);
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: tokenPair.refreshToken,
    );
  }

  Future<void> _clearSession() async {
    if (kIsWeb) {
      final preferences = _sharedPreferences ?? SharedPreferencesAsync();
      await preferences.remove(_tokenKey);
      await preferences.remove(_refreshTokenKey);
      await preferences.remove(_loginKey);
      await preferences.remove(_fullNameKey);
      return;
    }

    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _loginKey);
    await _secureStorage.delete(key: _fullNameKey);
  }

  Dio _createDio([BaseOptions? options]) {
    final dio = Dio(options);
    final httpClientAdapter = _httpClientAdapter;
    if (httpClientAdapter != null) {
      dio.httpClientAdapter = httpClientAdapter;
    }
    return dio;
  }

  bool _isAuthRequest(String path) {
    return path.startsWith('/auth/') || path.contains('/api/v1/auth/');
  }
}

final class _TokenPair {
  const _TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}
