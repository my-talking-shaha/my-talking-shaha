import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
    SharedPreferencesAsync? sharedPreferences,
  }) : _secureStorage = secureStorage,
       _sharedPreferences = sharedPreferences;

  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferencesAsync? _sharedPreferences;

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

  Future<String?> _readToken() {
    if (kIsWeb) {
      return (_sharedPreferences ?? SharedPreferencesAsync()).getString(
        _tokenKey,
      );
    }

    return _secureStorage.read(key: _tokenKey);
  }

  bool _isAuthRequest(String path) {
    return path.startsWith('/auth/') || path.contains('/api/v1/auth/');
  }
}
