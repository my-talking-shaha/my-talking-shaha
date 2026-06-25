import 'package:frontend/features/auth/data/datasources/auth_datasource.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';

final class MockAuthDatasource implements AuthDatasource {
  MockAuthDatasource({this.delay = const Duration(milliseconds: 700)});

  final Duration delay;
  final Map<String, _MockAccount> _accounts = {
    'driver@example.com': const _MockAccount(
      fullName: 'Demo Driver',
      email: 'driver@example.com',
      password: 'password123',
    ),
  };

  @override
  Future<AuthSession> register(RegistrationCredentials credentials) async {
    await Future<void>.delayed(delay);
    final normalized = credentials.trimmed();
    final email = normalized.email.toLowerCase();

    if (!_isStrongPassword(normalized.password)) {
      throw const AuthException(
        AuthErrorCode.validation,
        'The password does not satisfy the requirements',
      );
    }

    if (email == 'existing@example.com' || _accounts.containsKey(email)) {
      throw const AuthException(
        AuthErrorCode.conflict,
        'Email already exists',
      );
    }

    final account = _MockAccount(
      fullName: normalized.fullName,
      email: email,
      password: normalized.password,
    );
    _accounts[email] = account;

    return _sessionFor(account);
  }

  @override
  Future<AuthSession> login(LoginCredentials credentials) async {
    await Future<void>.delayed(delay);
    final normalized = credentials.trimmed();
    final email = normalized.email.toLowerCase();

    if (email == 'network@example.com') {
      throw const AuthException(
        AuthErrorCode.network,
        'Network error. Please try again later',
      );
    }

    final account = _accounts[email];
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

  bool _isStrongPassword(String password) {
    return password.length >= 8;
  }

  AuthSession _sessionFor(_MockAccount account) {
    return AuthSession(
      token: 'mock-token-${account.email}',
      email: account.email,
      fullName: account.fullName,
    );
  }
}

final class _MockAccount {
  const _MockAccount({
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String email;
  final String password;
}
