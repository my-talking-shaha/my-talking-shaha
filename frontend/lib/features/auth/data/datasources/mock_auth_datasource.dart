import 'package:frontend/features/auth/data/datasources/auth_datasource.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/utils/validator.dart';

final class MockAuthDatasource implements AuthDatasource {
  MockAuthDatasource({this.delay = const Duration(milliseconds: 700)});

  final Duration delay;
  final Map<String, _MockAccount> _accounts = {
    'driver': const _MockAccount(
      fullName: 'Demo Driver',
      login: 'driver',
      password: 'password123',
    ),
  };

  @override
  Future<AuthSession> register(RegistrationCredentials credentials) async {
    await Future<void>.delayed(delay);
    final normalized = credentials.trimmed();
    final login = normalized.login.toLowerCase();

    if (!AuthValidator.isStrongPassword(normalized.password)) {
      throw const AuthException(
        AuthErrorCode.validation,
        'The password does not satisfy the requirements',
      );
    }

    if (login == 'existing' || _accounts.containsKey(login)) {
      throw const AuthException(
        AuthErrorCode.conflict,
        'Login already exists',
      );
    }

    final account = _MockAccount(
      fullName: normalized.fullName,
      login: login,
      password: normalized.password,
    );
    _accounts[login] = account;

    return _sessionFor(account);
  }

  @override
  Future<AuthSession> login(LoginCredentials credentials) async {
    await Future<void>.delayed(delay);
    final normalized = credentials.trimmed();
    final login = normalized.login.toLowerCase();

    if (login == 'network') {
      throw const AuthException(
        AuthErrorCode.network,
        'Network error. Please try again later',
      );
    }

    final account = _accounts[login];
    if (account == null || account.password != normalized.password) {
      throw const AuthException(
        AuthErrorCode.unauthorized,
        'Login or password are incorrect',
      );
    }

    return _sessionFor(account);
  }

  @override
  Future<void> logout(String token) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  AuthSession _sessionFor(_MockAccount account) {
    return AuthSession(
      token: 'mock-token-${account.login}',
      login: account.login,
      fullName: account.fullName,
    );
  }
}

final class _MockAccount {
  const _MockAccount({
    required this.fullName,
    required this.login,
    required this.password,
  });

  final String fullName;
  final String login;
  final String password;
}
