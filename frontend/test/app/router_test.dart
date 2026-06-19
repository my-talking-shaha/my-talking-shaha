import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/router.dart';
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
}

Future<_TestApp> _pumpApp(
  WidgetTester tester, {
  String? initialLocation,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final router = container.read(routerProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const CarApp()),
  );

  if (initialLocation != null) {
    router.go(initialLocation);
  }

  await tester.pumpAndSettle();
  return _TestApp(router);
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
  const _TestApp(this.router);

  final GoRouter router;
}
