import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/auth/di/auth_providers.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_exception.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/colors.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/registration_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('auth palette preserves the pre-refactoring ARGB values', () {
    expect(
      <int>[
        AuthColors.background.toARGB32(),
        AuthColors.surface.toARGB32(),
        AuthColors.surfaceHigh.toARGB32(),
        AuthColors.surfaceHighest.toARGB32(),
        AuthColors.border.toARGB32(),
        AuthColors.formBorder.toARGB32(),
        AuthColors.primary.toARGB32(),
        AuthColors.primaryLight.toARGB32(),
        AuthColors.textPrimary.toARGB32(),
        AuthColors.textSecondary.toARGB32(),
        AuthColors.textMuted.toARGB32(),
        AuthColors.textDisabled.toARGB32(),
        AuthColors.error.toARGB32(),
        AuthColors.white.toARGB32(),
        AuthColors.black.toARGB32(),
      ],
      <int>[
        0xFF10131A,
        0xFF191A21,
        0xFF1C1F25,
        0xFF232731,
        0xFF2B303B,
        0xFF3A4153,
        0xFF2E5BFF,
        0xFFB8C3FF,
        0xFFF4F7FF,
        0xFF9AA3B2,
        0xFF6F7788,
        0xFF4B5263,
        0xFFE85D75,
        0xFFFFFFFF,
        0xFF000000,
      ],
    );
  });

  testWidgets('login keeps validation, visibility, and error behavior', (
    tester,
  ) async {
    final repository = _FakeAuthRepository(
      loginError: const AuthException(
        AuthErrorCode.unauthorized,
        'Invalid credentials',
      ),
    );
    await _pumpAuthApp(tester, repository: repository);

    expect(_editableFields(tester).last.obscureText, isTrue);

    await tester.tap(find.text('Log in').last);
    await tester.pump();
    expect(find.text('Enter your email'), findsNWidgets(2));
    expect(find.text('Enter your password'), findsOneWidget);
    expect(repository.loginCalls, 0);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(_editableFields(tester).last.obscureText, isFalse);

    await tester.tap(find.text('Log in').last);
    await tester.pumpAndSettle();
    expect(repository.loginCalls, 1);
    expect(repository.lastLogin?.login, 'user@example.com');
    expect(find.text('Invalid credentials'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'next@example.com',
    );
    await tester.pump();
    expect(find.text('Invalid credentials'), findsNothing);
  });

  testWidgets('registration keeps shared password visibility and validation', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await _pumpAuthApp(
      tester,
      repository: repository,
      initialLocation: '/registration',
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'user@example.com');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'different');
    await tester.ensureVisible(find.text('Register').last);
    await tester.tap(find.text('Register').last);
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(repository.registerCalls, 0);

    await tester.ensureVisible(find.byTooltip('Show password'));
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(_editableFields(tester).skip(2).map((field) => field.obscureText), [
      false,
      false,
    ]);

    await tester.enterText(fields.at(3), 'secret1');
    await tester.ensureVisible(find.text('Register').last);
    await tester.tap(find.text('Register').last);
    await tester.pumpAndSettle();
    expect(repository.registerCalls, 1);
    expect(repository.lastRegistration?.fullName, 'Test User');
  });

  testWidgets('auth mode controls navigate without horizontal swipe behavior', (
    tester,
  ) async {
    await _pumpAuthApp(tester, repository: _FakeAuthRepository());

    await tester.drag(find.byType(LoginScreen), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.text('Register').first);
    await tester.pumpAndSettle();
    expect(find.byType(RegistrationScreen), findsOneWidget);

    await tester.tap(find.text('Log in').first);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}

List<EditableText> _editableFields(WidgetTester tester) {
  return tester.widgetList<EditableText>(find.byType(EditableText)).toList();
}

Future<void> _pumpAuthApp(
  WidgetTester tester, {
  required AuthRepository repository,
  String initialLocation = '/login',
}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/registration',
        builder: (_, _) => const RegistrationScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.loginError});

  final AuthException? loginError;
  int loginCalls = 0;
  int registerCalls = 0;
  LoginCredentials? lastLogin;
  RegistrationCredentials? lastRegistration;

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<AuthSession> login(LoginCredentials credentials) async {
    loginCalls += 1;
    lastLogin = credentials;
    if (loginError case final error?) throw error;
    return _session;
  }

  @override
  Future<AuthSession> register(RegistrationCredentials credentials) async {
    registerCalls += 1;
    lastRegistration = credentials;
    return _session;
  }

  @override
  Future<void> logout() async {}

  static const _session = AuthSession(
    token: 'token',
    login: 'user@example.com',
    fullName: 'Test User',
  );
}
