import 'package:frontend/features/auth/data/datasources/auth_datasource.dart';
import 'package:frontend/features/auth/data/datasources/auth_session_storage.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthDatasource datasource,
    required AuthSessionStorage storage,
  }) : _datasource = datasource,
       _storage = storage;

  final AuthDatasource _datasource;
  final AuthSessionStorage _storage;

  @override
  Future<AuthSession?> restoreSession() {
    return _storage.readSession();
  }

  @override
  Future<AuthSession> register(RegistrationCredentials credentials) async {
    final session = await _datasource.register(credentials);
    await _storage.saveSession(session);
    return session;
  }

  @override
  Future<AuthSession> login(LoginCredentials credentials) async {
    final session = await _datasource.login(credentials);
    await _storage.saveSession(session);
    return session;
  }

  @override
  Future<void> logout() async {
    final session = await _storage.readSession();
    if (session != null) {
      await _datasource.logout(session.token);
    }
    await _storage.clearSession();
  }
}
