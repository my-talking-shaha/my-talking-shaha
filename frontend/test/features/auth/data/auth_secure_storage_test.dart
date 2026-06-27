import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/datasources/auth_secure_storage.dart';

void main() {
  late FlutterSecureStoragePlatform originalPlatform;

  setUp(() {
    originalPlatform = FlutterSecureStoragePlatform.instance;
  });

  tearDown(() {
    FlutterSecureStoragePlatform.instance = originalPlatform;
  });

  test('readSession restores a saved session', () async {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform({
      'auth_token': 'token',
      'auth_login': 'driver',
      'auth_full_name': 'Demo Driver',
    });

    final storage = AuthSecureStorage(
      const FlutterSecureStorage(),
      restoreSessionTimeout: const Duration(milliseconds: 50),
    );

    final session = await storage.readSession();

    expect(session?.token, 'token');
    expect(session?.login, 'driver');
    expect(session?.fullName, 'Demo Driver');
  });

  test(
    'readSession returns null when secure storage does not respond',
    () async {
      FlutterSecureStoragePlatform.instance = _HangingSecureStoragePlatform();
      final storage = AuthSecureStorage(
        const FlutterSecureStorage(),
        restoreSessionTimeout: const Duration(milliseconds: 10),
      );

      final session = await storage.readSession();

      expect(session, isNull);
    },
  );
}

final class _HangingSecureStoragePlatform
    extends TestFlutterSecureStoragePlatform {
  _HangingSecureStoragePlatform() : super({});

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) {
    return Completer<String?>().future;
  }
}
