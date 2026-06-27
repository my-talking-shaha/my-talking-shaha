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
        data: {
          'email': normalized.login,
          'password': normalized.password,
        },
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
    final backendCode = _backendCode(error.response?.data);

    if (statusCode == 409 || backendCode == 'EMAIL_ALREADY_EXISTS') {
      return const AuthException(
        AuthErrorCode.conflict,
        'Email already exists',
      );
    }

    if (statusCode == 401 || backendCode == 'INVALID_CREDENTIALS') {
      return const AuthException(
        AuthErrorCode.unauthorized,
        'Email or password are incorrect',
      );
    }

    if (statusCode == 400 || backendCode == 'VALIDATION_ERROR') {
      return const AuthException(
        AuthErrorCode.validation,
        'Check the entered data and try again',
      );
    }

    return const AuthException(
      AuthErrorCode.unknown,
      'Something went wrong. Please try again later',
    );
  }

  static String _backendCode(Object? data) {
    if (data is Map<String, dynamic>) {
      return data['code']?.toString().toUpperCase() ?? '';
    }

    return '';
  }
}
