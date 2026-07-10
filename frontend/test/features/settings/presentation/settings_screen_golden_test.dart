import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/features/auth/di/auth_providers.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/notifications/data/datasources/mock_notifications_datasource.dart';
import 'package:frontend/features/notifications/presentation/providers/notifications_providers.dart';
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

  testWidgets('settings screen preserves its visual baseline', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(const _GoldenAuthRepository()),
        notificationsDatasourceProvider.overrideWithValue(
          const MockNotificationsDatasource(delay: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    router.go('/settings');
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const CarApp()),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(CarApp),
      matchesGoldenFile('goldens/settings_screen.png'),
    );
  });
}

final class _GoldenAuthRepository implements AuthRepository {
  const _GoldenAuthRepository();

  @override
  Future<AuthSession?> restoreSession() async {
    return const AuthSession(
      token: 'golden-token',
      login: 'driver@example.com',
      fullName: 'Test Driver',
    );
  }

  @override
  Future<AuthSession> register(RegistrationCredentials credentials) {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> login(LoginCredentials credentials) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}
