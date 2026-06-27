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
        DioException(
          requestOptions: RequestOptions(path: '/auth/register'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/register'),
            statusCode: 409,
            data: const {'code': 'EMAIL_ALREADY_EXISTS'},
          ),
        ),
      );

      expect(exception.code, AuthErrorCode.conflict);
      expect(exception.message, 'Email already exists');
    });

    test('maps backend invalid credentials to unauthorized', () {
      final exception = AuthApiErrorMapper.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 401,
            data: const {'code': 'INVALID_CREDENTIALS'},
          ),
        ),
      );

      expect(exception.code, AuthErrorCode.unauthorized);
      expect(exception.message, 'Email or password are incorrect');
    });
  });
}
