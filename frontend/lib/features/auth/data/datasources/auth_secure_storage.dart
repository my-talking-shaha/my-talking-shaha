import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';

final class AuthSecureStorage {
  const AuthSecureStorage(this._storage);

  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';
  static const _fullNameKey = 'auth_full_name';

  final FlutterSecureStorage _storage;

  Future<AuthSession?> readSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }

    final email = await _storage.read(key: _emailKey);
    final fullName = await _storage.read(key: _fullNameKey);

    return AuthSession(
      token: token,
      email: email ?? '',
      fullName: fullName ?? '',
    );
  }

  Future<void> saveSession(AuthSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(key: _emailKey, value: session.email);
    await _storage.write(key: _fullNameKey, value: session.fullName);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _fullNameKey);
  }
}
