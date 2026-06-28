import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/datasources/shared_preferences_auth_session_storage.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SharedPreferencesAsyncPlatform? originalPlatform;

  setUp(() {
    originalPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = originalPlatform;
  });

  test('readSession restores a saved session', () async {
    final storage = SharedPreferencesAuthSessionStorage(
      SharedPreferencesAsync(),
    );

    await storage.saveSession(
      const AuthSession(
        token: 'token',
        refreshToken: 'refresh-token',
        login: 'driver',
        fullName: 'Demo Driver',
      ),
    );

    final session = await storage.readSession();

    expect(session?.token, 'token');
    expect(session?.refreshToken, 'refresh-token');
    expect(session?.login, 'driver');
    expect(session?.fullName, 'Demo Driver');
  });

  test('clearSession removes saved session', () async {
    final storage = SharedPreferencesAuthSessionStorage(
      SharedPreferencesAsync(),
    );

    await storage.saveSession(
      const AuthSession(
        token: 'token',
        refreshToken: 'refresh-token',
        login: 'driver',
        fullName: 'Demo Driver',
      ),
    );
    await storage.clearSession();

    final session = await storage.readSession();

    expect(session, isNull);
  });
}
