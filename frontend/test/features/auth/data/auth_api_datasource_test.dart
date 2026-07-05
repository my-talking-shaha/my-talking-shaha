import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:frontend/features/auth/domain/entities/auth_exception.dart';

void main() {
  group('AuthApiSessionMapper', () {
    test('maps backend auth response to session', () {
      final session = AuthApiSessionMapper.fromJson(const {
        'user': {
          'id': '045c10aa-13d1-4599-9109-e9e79789ea91',
          'email': 'driver@example.com',
          'displayName': 'Demo Driver',
        },
        'accessToken': 'jwt-access-token',
        'refreshToken': 'jwt-refresh-token',
      });

      expect(session.token, 'jwt-access-token');
      expect(session.refreshToken, 'jwt-refresh-token');
      expect(session.login, 'driver@example.com');
      expect(session.fullName, 'Demo Driver');
    });
  });

  group('AuthApiErrorMapper', () {
    test('maps backend conflict to auth conflict', () {
      final exception = AuthApiErrorMapper.fromDio(
        _dioError(
          path: '/auth/register',
          statusCode: 409,
          data: const {'code': 'EMAIL_ALREADY_EXISTS'},
        ),
      );

      expect(exception.code, AuthErrorCode.conflict);
      expect(
        exception.message,
        'This email is already registered. Log in instead.',
      );
    });

    test('maps backend validation fields to a readable validation message', () {
      final exception = AuthApiErrorMapper.fromDio(
        _dioError(
          path: '/auth/register',
          statusCode: 400,
          data: const {
            'code': 'VALIDATION_ERROR',
            'fields': {
              'email': 'must be a well-formed email address',
              'password': 'Password must be between 6 and 72 characters',
              'displayName': 'must not be blank',
            },
          },
        ),
      );

      expect(exception.code, AuthErrorCode.validation);
      expect(
        exception.message,
        'Check the entered data:\n'
        'Email: must be a well-formed email address\n'
        'Password: Password must be between 6 and 72 characters\n'
        'Full name: must not be blank',
      );
    });

    test('maps login invalid credentials to a registration-aware message', () {
      final exception = AuthApiErrorMapper.fromDio(
        _dioError(
          path: '/auth/login',
          statusCode: 401,
          data: const {'code': 'INVALID_CREDENTIALS'},
        ),
      );

      expect(exception.code, AuthErrorCode.unauthorized);
      expect(
        exception.message,
        'User not found or password is incorrect. Check your email and password, or register a new account.',
      );
    });

    test('maps refresh invalid credentials to a session message', () {
      final exception = AuthApiErrorMapper.fromDio(
        _dioError(
          path: '/auth/refresh',
          statusCode: 401,
          data: const {'code': 'INVALID_CREDENTIALS'},
        ),
      );

      expect(exception.code, AuthErrorCode.unauthorized);
      expect(exception.message, 'Session expired. Log in again.');
    });

    test('maps auth-required code before status fallback', () {
      final exception = AuthApiErrorMapper.fromDio(
        _dioError(
          path: '/users/me',
          statusCode: 401,
          data: const {'code': 'AUTHENTICATION_REQUIRED'},
        ),
      );

      expect(exception.code, AuthErrorCode.unauthorized);
      expect(exception.message, 'Session expired. Log in again.');
    });

    test('falls back to status code when backend code is missing', () {
      final exception = AuthApiErrorMapper.fromDio(
        _dioError(
          path: '/auth/register',
          statusCode: 409,
          data: const {'message': 'Email already registered'},
        ),
      );

      expect(exception.code, AuthErrorCode.conflict);
      expect(
        exception.message,
        'This email is already registered. Log in instead.',
      );
    });
  });
}

DioException _dioError({
  required String path,
  required int statusCode,
  required Map<String, Object?> data,
}) {
  final requestOptions = RequestOptions(path: path);
  return DioException(
    requestOptions: requestOptions,
    response: Response<Map<String, Object?>>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
  );
}
