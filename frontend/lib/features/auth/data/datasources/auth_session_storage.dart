import 'package:frontend/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthSessionStorage {
  Future<AuthSession?> readSession();

  Future<void> saveSession(AuthSession session);

  Future<void> clearSession();
}
