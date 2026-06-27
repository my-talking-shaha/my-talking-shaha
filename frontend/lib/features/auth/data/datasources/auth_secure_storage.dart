import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/auth/data/datasources/auth_session_storage.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';

final class SecureAuthSessionStorage implements AuthSessionStorage {
  const SecureAuthSessionStorage(
    this._storage, {
    this.restoreSessionTimeout = const Duration(seconds: 3),
  });

  static const _tokenKey = 'auth_token';
  static const _loginKey = 'auth_login';
  static const _fullNameKey = 'auth_full_name';

  final FlutterSecureStorage _storage;
  final Duration restoreSessionTimeout;

  @override
  Future<AuthSession?> readSession() async {
    try {
      return await _readSession().timeout(restoreSessionTimeout);
    } on TimeoutException {
      return null;
    }
  }

  Future<AuthSession?> _readSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }

    final login = await _storage.read(key: _loginKey);
    final fullName = await _storage.read(key: _fullNameKey);

    return AuthSession(
      token: token,
      login: login ?? '',
      fullName: fullName ?? '',
    );
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(key: _loginKey, value: session.login);
    await _storage.write(key: _fullNameKey, value: session.fullName);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _loginKey);
    await _storage.delete(key: _fullNameKey);
  }
}
