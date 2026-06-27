import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:frontend/features/notifications/data/datasources/mock_notifications_datasource.dart';
import 'package:frontend/features/notifications/presentation/providers/notifications_providers.dart';

void main() {
  testWidgets('profile renders MVP user controls', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Alex Driver'), findsOneWidget);
    expect(find.text('alex.driver@example.com'), findsOneWidget);
    expect(find.text('THEME'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('GENERAL'), findsOneWidget);
    expect(find.text('App language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('ENG'), findsOneWidget);
    expect(find.text('Notifications'), findsWidgets);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('VEHICLE'), findsOneWidget);
    expect(find.text('All notifications'), findsOneWidget);
    await tester.tap(find.text('ENG'));
    await tester.pumpAndSettle();

    expect(find.text('RU'), findsOneWidget);

    await tester.tap(find.text('RU'));
    await tester.pumpAndSettle();
    expect(find.text('Russian'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Log out'),
      find.byType(ListView),
      const Offset(0, -240),
    );

    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('profile opens notifications and details with back navigation', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.dragUntilVisible(
      find.byKey(const ValueKey('profile_all_notifications_action')),
      find.byType(ListView),
      const Offset(0, -360),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('profile_all_notifications_action')),
    );
    tester
        .widget<InkWell>(
          find.byKey(const ValueKey('profile_all_notifications_action')),
        )
        .onTap!();
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsWidgets);
    expect(find.text('Oil service is coming soon'), findsOneWidget);
    expect(
      find.textContaining('Plan a service visit this week'),
      findsOneWidget,
    );
    final preview = tester.widget<Text>(
      find.byKey(const ValueKey('notification_preview_notif_engine_oil')),
    );
    expect(preview.maxLines, 2);
    expect(preview.data, endsWith('...'));

    await tester.tap(find.text('Oil service is coming soon'));
    await tester.pumpAndSettle();

    expect(find.text('Notification details'), findsOneWidget);
    expect(find.text('Schedule an oil change'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Oil service is coming soon'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Alex Driver'),
      find.byType(ListView),
      const Offset(0, 320),
    );
    expect(find.text('Alex Driver'), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider
          .overrideWithValue(const _AuthenticatedRepository()),
      notificationsDatasourceProvider.overrideWithValue(
        const MockNotificationsDatasource(delay: Duration.zero),
      ),
    ],
  );
  addTearDown(container.dispose);

  final router = container.read(routerProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const CarApp()),
  );

  router.go('/settings');
  await tester.pumpAndSettle();
}

final class _AuthenticatedRepository implements AuthRepository {
  const _AuthenticatedRepository();

  @override
  Future<AuthSession?> restoreSession() async {
    return const AuthSession(
      token: 'test-token',
      login: 'driver',
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
