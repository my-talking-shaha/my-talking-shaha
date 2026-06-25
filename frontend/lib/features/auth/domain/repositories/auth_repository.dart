import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession?> restoreSession();

  Future<AuthSession> register(RegistrationCredentials credentials);

  Future<AuthSession> login(LoginCredentials credentials);

  Future<void> logout();
}
