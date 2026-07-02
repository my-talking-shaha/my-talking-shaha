import 'package:dio/dio.dart';
import 'package:frontend/features/auth/data/datasources/auth_datasource.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';

final class AuthApiDatasource implements AuthDatasource {
  const AuthApiDatasource(this._dio);

  final Dio _dio;

  @override
  Future<AuthSession> register(RegistrationCredentials credentials) async {
    final normalized = credentials.trimmed();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': normalized.login,
          'password': normalized.password,
          'displayName': normalized.fullName,
        },
      );

      return AuthApiSessionMapper.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw AuthApiErrorMapper.fromDio(error);
    }
  }

  @override
  Future<AuthSession> login(LoginCredentials credentials) async {
    final normalized = credentials.trimmed();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': normalized.login, 'password': normalized.password},
      );

      return AuthApiSessionMapper.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw AuthApiErrorMapper.fromDio(error);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    if (refreshToken.isEmpty) {
      return;
    }

    try {
      await _dio.post<void>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (error) {
      throw AuthApiErrorMapper.fromDio(error);
    }
  }
}

abstract final class AuthApiSessionMapper {
  static AuthSession fromJson(Map<String, dynamic> json) {
    final user = _mapValue(json['user']);

    return AuthSession(
      token: _stringValue(json['accessToken']),
      refreshToken: _stringValue(json['refreshToken']),
      login: _stringValue(user['email']),
      fullName: _stringValue(user['displayName']),
    );
  }

  static Map<String, dynamic> _mapValue(Object? value) {
    return value is Map<String, dynamic> ? value : const {};
  }

  static String _stringValue(Object? value) {
    return value?.toString() ?? '';
  }
}

abstract final class AuthApiErrorMapper {
  static AuthException fromDio(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const AuthException(
        AuthErrorCode.network,
        'Network error. Please try again later',
      );
    }

    final statusCode = error.response?.statusCode;
    final apiError = AuthBackendApiError.fromJson(error.response?.data);
    final backendCode = AuthBackendErrorCode.fromCode(apiError.code);
    final path = error.requestOptions.path;

    switch (backendCode) {
      case AuthBackendErrorCode.validationError:
        return AuthException(
          AuthErrorCode.validation,
          _validationMessage(apiError.fields),
        );
      case AuthBackendErrorCode.emailAlreadyExists:
        return const AuthException(
          AuthErrorCode.conflict,
          'This email is already registered. Log in instead.',
        );
      case AuthBackendErrorCode.invalidCredentials:
        return AuthException(
          AuthErrorCode.unauthorized,
          _invalidCredentialsMessage(path),
        );
      case AuthBackendErrorCode.authenticationRequired:
        return const AuthException(
          AuthErrorCode.unauthorized,
          'Session expired. Log in again.',
        );
      case AuthBackendErrorCode.notFound:
        return const AuthException(
          AuthErrorCode.unknown,
          'Account not found. Register a new account.',
        );
      case AuthBackendErrorCode.forbidden:
        return const AuthException(
          AuthErrorCode.unauthorized,
          'You do not have access to this account.',
        );
      case AuthBackendErrorCode.unknown:
        break;
    }

    if (statusCode == 400) {
      return const AuthException(
        AuthErrorCode.validation,
        'Check the entered data and try again.',
      );
    }

    if (statusCode == 401) {
      return AuthException(
        AuthErrorCode.unauthorized,
        _invalidCredentialsMessage(path),
      );
    }

    if (statusCode == 409) {
      return const AuthException(
        AuthErrorCode.conflict,
        'This email is already registered. Log in instead.',
      );
    }

    return const AuthException(
      AuthErrorCode.unknown,
      'Something went wrong. Please try again later',
    );
  }

  static String _invalidCredentialsMessage(String path) {
    if (path.endsWith('/login')) {
      return 'User not found or password is incorrect. Check your email and password, or register a new account.';
    }

    return 'Session expired. Log in again.';
  }

  static String _validationMessage(Map<String, String> fields) {
    if (fields.isEmpty) {
      return 'Check the entered data and try again.';
    }

    final details = fields.entries
        .map((entry) => '${_fieldLabel(entry.key)}: ${entry.value}')
        .join('\n');
    return 'Check the entered data:\n$details';
  }

  static String _fieldLabel(String field) {
    return switch (field) {
      'email' => 'Email',
      'password' => 'Password',
      'displayName' => 'Full name',
      'refreshToken' => 'Session',
      _ => field,
    };
  }
}

enum AuthBackendErrorCode {
  validationError,
  emailAlreadyExists,
  invalidCredentials,
  authenticationRequired,
  notFound,
  forbidden,
  unknown;

  static AuthBackendErrorCode fromCode(String code) {
    return switch (code.toUpperCase()) {
      'VALIDATION_ERROR' => validationError,
      'EMAIL_ALREADY_EXISTS' => emailAlreadyExists,
      'INVALID_CREDENTIALS' => invalidCredentials,
      'AUTHENTICATION_REQUIRED' => authenticationRequired,
      'NOT_FOUND' => notFound,
      'FORBIDDEN' => forbidden,
      _ => unknown,
    };
  }
}

final class AuthBackendApiError {
  const AuthBackendApiError({required this.code, required this.fields});

  final String code;
  final Map<String, String> fields;

  static AuthBackendApiError fromJson(Object? data) {
    if (data is! Map) {
      return const AuthBackendApiError(code: '', fields: {});
    }

    return AuthBackendApiError(
      code: data['code']?.toString() ?? '',
      fields: _fieldsValue(data['fields']),
    );
  }

  static Map<String, String> _fieldsValue(Object? value) {
    if (value is! Map) {
      return const {};
    }

    return value.map((key, value) {
      return MapEntry(key.toString(), value?.toString() ?? '');
    });
  }
}
