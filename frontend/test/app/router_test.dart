import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/garage/data/datasources/in_memory_garage_datasource.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';
import 'package:frontend/features/history/data/datasources/mock_history_datasource.dart';
import 'package:frontend/features/history/presentation/providers/history_providers.dart';
import 'package:frontend/features/history/presentation/screens/add_history_event_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('tab routes are hosted in an indexed stack', (tester) async {
    await _pumpApp(tester, initialLocation: '/vehicle/vehicle_123/chat');

    expect(find.byType(IndexedStack), findsOneWidget);
  });

  testWidgets('five destination bar uses a fixed layout', (tester) async {
    await _pumpApp(tester, initialLocation: '/vehicle/vehicle_123/chat');

    expect(_navigationBar(tester).items, hasLength(5));
    expect(_navigationBar(tester).type, BottomNavigationBarType.fixed);
    expect(_destinationLabels(tester), [
      'Dashboard',
      'History',
      'Chat',
      'Analytics',
      'Settings',
    ]);
  });

  testWidgets('garage shows only garage and settings without a vehicle', (
    tester,
  ) async {
    final app = await _pumpApp(tester);

    expect(_destinationLabels(tester), ['Garage', 'Settings']);
    for (final label in ['History', 'Chat', 'Analytics']) {
      expect(_destination(label), findsNothing);
    }
    expect(_navigationBar(tester).currentIndex, 0);

    await tester.tap(_destination('Settings'));
    await tester.pumpAndSettle();

    expect(
      app.router.routeInformationProvider.value.uri,
      Uri(path: '/settings'),
    );
    expect(_destinationLabels(tester), ['Garage', 'Settings']);
    expect(_navigationBar(tester).currentIndex, 1);
  });

  testWidgets(
    'vehicle routes select their tab and preserve vehicle context through settings',
    (tester) async {
      final app = await _pumpApp(
        tester,
        initialLocation: '/vehicle/vehicle_123/chat',
      );

      expect(_navigationBar(tester).currentIndex, 2);

      await tester.tap(_destination('Dashboard'));
      await tester.pumpAndSettle();

      expect(
        app.router.routeInformationProvider.value.uri.path,
        '/vehicle/vehicle_123/dashboard',
      );
      expect(_navigationBar(tester).currentIndex, 0);
      expect(find.byType(DashboardScreen), findsOneWidget);

      await tester.tap(_destination('History'));
      await tester.pumpAndSettle();

      expect(
        app.router.routeInformationProvider.value.uri.path,
        '/vehicle/vehicle_123/history',
      );
      expect(_navigationBar(tester).currentIndex, 1);

      await tester.tap(_destination('Analytics'));
      await tester.pumpAndSettle();

      expect(
        app.router.routeInformationProvider.value.uri.path,
        '/vehicle/vehicle_123/analytics',
      );
      expect(_navigationBar(tester).currentIndex, 3);

      await tester.tap(_destination('Settings'));
      await tester.pumpAndSettle();

      expect(
        app.router.routeInformationProvider.value.uri,
        Uri(path: '/settings', queryParameters: {'vehicleId': 'vehicle_123'}),
      );
      expect(_navigationBar(tester).currentIndex, 4);

      await tester.tap(_destination('Chat'));
      await tester.pumpAndSettle();

      expect(
        app.router.routeInformationProvider.value.uri.path,
        '/vehicle/vehicle_123/chat',
      );
      expect(_navigationBar(tester).currentIndex, 2);
    },
  );

  testWidgets('history add route opens outside the tab shell', (tester) async {
    await _pumpApp(tester, initialLocation: '/vehicle/vehicle_123/history/add');

    expect(find.byType(AddHistoryEventScreen), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    final screen = tester.widget<AddHistoryEventScreen>(
      find.byType(AddHistoryEventScreen),
    );
    expect(screen.vehicleId, 'vehicle_123');
    expect(screen.initialMileageKm, 0);
    final mileageField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const ValueKey('fuel-mileage')),
        matching: find.byType(TextFormField),
      ),
    );
    expect(mileageField.controller?.text, isEmpty);
  });

  testWidgets('history add button opens the form and saves an event', (
    tester,
  ) async {
    final app = await _pumpApp(
      tester,
      initialLocation: '/vehicle/vehicle_123/history',
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(AddHistoryEventScreen), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Highway refueling',
    );
    await tester.enterText(
      find.byKey(const ValueKey('fuel-mileage')),
      '124600',
    );
    await tester.enterText(find.byKey(const ValueKey('fuel-liters')), '42');
    await tester.enterText(find.byKey(const ValueKey('fuel-cost')), '3000');
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.dragUntilVisible(
      saveButton,
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.byType(AddHistoryEventScreen), findsNothing);
    final eventsFuture =
        app.container.read(historyRepositoryProvider).getEvents('vehicle_123');
    await tester.pump(const Duration(milliseconds: 600));
    final events = await eventsFuture;
    expect(events.any((event) => event.title == 'Highway refueling'), isTrue);
    expect(find.text('Highway refueling'), findsOneWidget);
  });
}

Future<_TestApp> _pumpApp(
  WidgetTester tester, {
  String? initialLocation,
}) async {
  final garageDatasource = InMemoryGarageDatasource();
  final historyDatasource = MockHistoryDatasource(delay: Duration.zero);
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider
          .overrideWithValue(const _AuthenticatedRepository()),
      garageDatasourceProvider.overrideWithValue(garageDatasource),
      historyDatasourceProvider.overrideWithValue(historyDatasource),
    ],
  );
  addTearDown(container.dispose);

  final router = container.read(routerProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const CarApp()),
  );

  if (initialLocation != null) {
    router.go(initialLocation);
  }

  await tester.pumpAndSettle();
  return _TestApp(router, container);
}

BottomNavigationBar _navigationBar(WidgetTester tester) {
  return tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
}

Finder _destination(String label) {
  return find.byTooltip(label);
}

List<String> _destinationLabels(WidgetTester tester) {
  return _navigationBar(
    tester,
  ).items.map((destination) => destination.label ?? '').toList();
}

final class _TestApp {
  const _TestApp(this.router, this.container);

  final GoRouter router;
  final ProviderContainer container;
}

final class _AuthenticatedRepository implements AuthRepository {
  const _AuthenticatedRepository();

  @override
  Future<AuthSession?> restoreSession() async {
    return const AuthSession(
      token: 'test-token',
      email: 'driver@example.com',
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
