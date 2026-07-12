import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/auth/di/auth_providers.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/notifications/data/datasources/mock_notifications_datasource.dart';
import 'package:frontend/features/notifications/di/notifications_providers.dart';
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

  testWidgets('profile renders MVP user controls', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Test Driver'), findsOneWidget);
    expect(find.text('driver'), findsOneWidget);
    expect(find.text('THEME'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('GENERAL'), findsOneWidget);
    expect(find.text('App language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('Notifications'), findsWidgets);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('VEHICLE'), findsOneWidget);
    expect(find.text('All notifications'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('Russian (RU)'), findsOneWidget);

    await tester.tap(find.text('Russian (RU)'));
    await tester.pumpAndSettle();
    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('Профиль'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Выйти'),
      find.byType(ListView),
      const Offset(0, -240),
    );

    expect(find.text('Выйти'), findsOneWidget);
  });

  testWidgets(
      'theme control changes the app theme and notifications stay local', (
    tester,
  ) async {
    await _pumpApp(tester);

    Color segmentColor(String label) {
      final segment = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(AnimatedContainer),
        ),
      );
      return (segment.decoration! as BoxDecoration).color!;
    }

    expect(segmentColor('Dark'), AppColors.primary);
    expect(segmentColor('Light'), Colors.transparent);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(segmentColor('Light'), AppColors.primary);
    expect(segmentColor('Dark'), Colors.transparent);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('profile restores selected theme on next launch', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await _pumpApp(tester);

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light);
  });

  testWidgets('settings list responds only to vertical scrolling', (
    tester,
  ) async {
    await _pumpApp(tester);

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.pixels, 0);

    await tester.drag(find.byType(ListView), const Offset(-280, 0));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, 0);

    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));

    await tester.drag(find.byType(ListView), const Offset(0, 640));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, 0);
  });

  testWidgets('profile restores selected language on next launch', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Russian (RU)'));
    await tester.pumpAndSettle();

    expect(find.text('Профиль'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await _pumpApp(tester);

    expect(find.text('Профиль'), findsOneWidget);
    expect(find.text('Язык приложения'), findsOneWidget);
    expect(find.text('RU'), findsOneWidget);
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
      find.text('Test Driver'),
      find.byType(ListView),
      const Offset(0, 320),
    );
    expect(find.text('Test Driver'), findsOneWidget);
  });

  testWidgets('successful logout returns to login', (tester) async {
    await _pumpApp(tester);

    await tester.dragUntilVisible(
      find.text('Log out'),
      find.byType(ListView),
      const Offset(0, -320),
    );
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('failed logout keeps profile open and shows localized error', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      repository: const _AuthenticatedRepository(logoutFails: true),
    );

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Russian (RU)'));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Выйти'),
      find.byType(ListView),
      const Offset(0, -320),
    );
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();

    expect(find.text('Профиль'), findsOneWidget);
    expect(find.text('Не удалось выйти. Попробуйте снова'), findsOneWidget);
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  AuthRepository repository = const _AuthenticatedRepository(),
}) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
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
  const _AuthenticatedRepository({this.logoutFails = false});

  final bool logoutFails;

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
  Future<void> logout() async {
    if (logoutFails) {
      throw StateError('logout failed');
    }
  }
}
