import 'package:frontend/features/auth/data/datasources/auth_session_storage.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SharedPreferencesAuthSessionStorage implements AuthSessionStorage {
  const SharedPreferencesAuthSessionStorage(this._preferences);

  static const _tokenKey = 'auth_token';
  static const _loginKey = 'auth_login';
  static const _fullNameKey = 'auth_full_name';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AuthSession?> readSession() async {
    final token = await _preferences.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }

    final login = await _preferences.getString(_loginKey);
    final fullName = await _preferences.getString(_fullNameKey);

    return AuthSession(
      token: token,
      login: login ?? '',
      fullName: fullName ?? '',
    );
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await _preferences.setString(_tokenKey, session.token);
    await _preferences.setString(_loginKey, session.login);
    await _preferences.setString(_fullNameKey, session.fullName);
  }

  @override
  Future<void> clearSession() async {
    await _preferences.remove(_tokenKey);
    await _preferences.remove(_loginKey);
    await _preferences.remove(_fullNameKey);
  }
}
