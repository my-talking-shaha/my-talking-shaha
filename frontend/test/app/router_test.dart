import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/providers/history_mutation_invalidation_provider.dart';
import 'package:frontend/app/providers/vehicle_mileage_provider.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/features/analytics/di/analytics_providers.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/features/auth/di/auth_providers.dart';
import 'package:frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:frontend/features/auth/domain/entities/auth_session.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/common/auth_mode_switch.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/features/chat/di/chat_providers.dart';
import 'package:frontend/features/chat/domain/entities/chat_action.dart';
import 'package:frontend/features/chat/domain/entities/chat_message.dart';
import 'package:frontend/features/chat/domain/entities/chat_state.dart';
import 'package:frontend/features/chat/domain/entities/send_message_result.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:frontend/features/dashboard/di/dashboard_providers.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/garage/data/datasources/garage_datasource.dart';
import 'package:frontend/features/garage/data/datasources/in_memory_garage_datasource.dart';
import 'package:frontend/features/garage/di/garage_providers.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/history/data/datasources/history_datasource.dart';
import 'package:frontend/features/history/data/datasources/mock_history_datasource.dart';
import 'package:frontend/features/history/di/history_providers.dart';
import 'package:frontend/features/history/di/live_trip_providers.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';
import 'package:frontend/features/history/domain/repositories/live_trip_repository.dart';
import 'package:frontend/features/history/presentation/screens/add_history_event_screen.dart';
import 'package:frontend/features/parts/di/parts_providers.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('restores an active trip from the app root', (tester) async {
    final liveTripRepository = _RecordingLiveTripRepository();

    await _pumpApp(tester, liveTripRepository: liveTripRepository);

    expect(liveTripRepository.restoreCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('auth loading route times out to login when restore hangs', (
    tester,
  ) async {
    final app = await _pumpApp(
      tester,
      authRepository: const _HangingAuthRepository(),
      settle: false,
    );

    await tester.pump();

    expect(app.router.routeInformationProvider.value.uri.path, '/auth');
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(
      AuthController.restoreSessionTimeout + const Duration(milliseconds: 1),
    );
    await tester.pump();

    expect(app.container.read(authControllerProvider).hasValue, isTrue);
    expect(app.router.routeInformationProvider.value.uri.path, '/login');
  });

  testWidgets('login screen prominently offers registration', (tester) async {
    final app = await _pumpApp(
      tester,
      authRepository: const _UnauthenticatedRepository(),
    );

    expect(app.router.routeInformationProvider.value.uri.path, '/login');
    final l10n = AppLocalizations.of(
      tester.element(find.byType(SegmentedButton<AuthMode>)),
    );
    expect(
      find.widgetWithText(SegmentedButton<AuthMode>, l10n.logIn),
      findsOne,
    );
    expect(
      find.widgetWithText(SegmentedButton<AuthMode>, l10n.register),
      findsOne,
    );
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<AuthMode>),
        matching: find.text(l10n.register),
      ),
    );
    await tester.pumpAndSettle();

    expect(app.router.routeInformationProvider.value.uri.path, '/registration');
    expect(
      find.widgetWithText(SegmentedButton<AuthMode>, l10n.logIn),
      findsOne,
    );
    expect(
      find.widgetWithText(SegmentedButton<AuthMode>, l10n.register),
      findsOne,
    );
  });

  testWidgets('tab routes are hosted in an indexed stack', (tester) async {
    await _pumpApp(
      tester,
      initialLocation: '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/chat',
    );

    expect(find.byType(IndexedStack), findsOneWidget);
  });

  testWidgets('five destination bar uses a fixed layout', (tester) async {
    await _pumpApp(
      tester,
      initialLocation: '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/chat',
    );

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

  testWidgets('invalid vehicle route falls back to garage before API screens', (
    tester,
  ) async {
    final app = await _pumpApp(
      tester,
      initialLocation: '/vehicle/vehicle_123/dashboard',
    );

    expect(app.router.routeInformationProvider.value.uri.path, '/garage');
    expect(find.byType(DashboardScreen), findsNothing);
    expect(_destinationLabels(tester), ['Garage', 'Settings']);
  });

  testWidgets(
    'vehicle routes select their tab and preserve vehicle context through settings',
    (tester) async {
      final app = await _pumpApp(
        tester,
        initialLocation: '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/chat',
      );

      expect(_navigationBar(tester).currentIndex, 2);

      await tester.tap(_destination('Dashboard'));
      await tester.pumpAndSettle();

      expect(
        app.router.routeInformationProvider.value.uri.path,
        '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/dashboard',
      );
      expect(_navigationBar(tester).currentIndex, 0);
      expect(find.byType(DashboardScreen), findsOneWidget);

      await tester.tap(_destination('History'));
      await tester.pumpAndSettle();

      expect(
        app.router.routeInformationProvider.value.uri.path,
        '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/history',
      );
      expect(_navigationBar(tester).currentIndex, 1);

      await tester.tap(_destination('Analytics'));
      await tester.pumpAndSettle();

      expect(
        app.router.routeInformationProvider.value.uri.path,
        '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/analytics',
      );
      expect(_navigationBar(tester).currentIndex, 3);

      await tester.tap(_destination('Settings'));
      await tester.pumpAndSettle();

      expect(
        app.router.routeInformationProvider.value.uri,
        Uri(
          path: '/settings',
          queryParameters: {
            'vehicleId': '096c10bb-13d1-4599-9109-e9e79789ea88',
          },
        ),
      );
      expect(_navigationBar(tester).currentIndex, 4);

      await tester.tap(_destination('Chat'));
      await tester.pumpAndSettle();

      expect(
        app.router.routeInformationProvider.value.uri.path,
        '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/chat',
      );
      expect(_navigationBar(tester).currentIndex, 2);
    },
  );

  testWidgets('chat screen links select destination tab and return to chat', (
    tester,
  ) async {
    const vehicleId = '096c10bb-13d1-4599-9109-e9e79789ea88';
    final app = await _pumpApp(
      tester,
      initialLocation: '/vehicle/$vehicleId/chat',
      chatRepository: const _ActionChatRepository(screen: 'ANALYTICS'),
    );

    expect(_navigationBar(tester).currentIndex, 2);

    await tester.tap(find.byKey(const ValueKey('chat_message_action')));
    await tester.pumpAndSettle();

    expect(
      app.router.routeInformationProvider.value.uri,
      Uri(
        path: '/vehicle/$vehicleId/analytics',
        queryParameters: {'from': 'chat'},
      ),
    );
    expect(_navigationBar(tester).currentIndex, 3);
    expect(find.byTooltip('Back to chat'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to chat'));
    await tester.pumpAndSettle();

    expect(
      app.router.routeInformationProvider.value.uri.path,
      '/vehicle/$vehicleId/chat',
    );
    expect(_navigationBar(tester).currentIndex, 2);
  });

  testWidgets('chat created-event editor handles the system back action', (
    tester,
  ) async {
    const vehicleId = '096c10bb-13d1-4599-9109-e9e79789ea88';
    final historyDatasource = _editableHistoryDatasource(
      vehicleId,
      isRecharge: true,
    );
    final app = await _pumpApp(
      tester,
      initialLocation: '/vehicle/$vehicleId/chat',
      historyDatasource: historyDatasource,
      chatRepository: const _ActionChatRepository(
        screen: 'HISTORY_EVENT_EDIT',
        prefill: {'eventId': 'fuel_1', 'eventType': 'RECHARGE'},
      ),
    );
    await app.container.read(vehicleEngineTypeProvider(vehicleId).future);
    await app.container.read(vehicleMileageProvider(vehicleId).future);
    app.container.read(historyMutationInvalidationProvider)(vehicleId);
    await tester.tap(find.byKey(const ValueKey('chat_message_action')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    expect(
      app.router.routeInformationProvider.value.uri.path,
      '/vehicle/$vehicleId/history/fuel_1/edit',
    );
    expect(app.router.routeInformationProvider.value.uri.queryParameters, {
      'from': 'chat',
    });
    final editor = tester.widget<AddHistoryEventScreen>(
      find.byType(AddHistoryEventScreen),
    );
    expect(editor.initialEvent?.id, 'fuel_1');
    expect(find.text('Edit recharge'), findsOneWidget);
    expect(find.byTooltip('Back to chat'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(
      app.router.routeInformationProvider.value.uri.path,
      '/vehicle/$vehicleId/chat',
    );
  });

  testWidgets('saving a chat-created event refreshes cached history', (
    tester,
  ) async {
    const vehicleId = '096c10bb-13d1-4599-9109-e9e79789ea88';
    final historyDatasource = _editableHistoryDatasource(vehicleId);
    final app = await _pumpApp(
      tester,
      initialLocation: '/vehicle/$vehicleId/chat',
      historyDatasource: historyDatasource,
      chatRepository: const _ActionChatRepository(
        screen: 'HISTORY_EVENT_EDIT',
        prefill: {'eventId': 'fuel_1', 'eventType': 'REFUEL'},
      ),
    );
    final historySubscription = app.container.listen(
      historyEventsProvider(vehicleId),
      (previous, next) {},
    );
    addTearDown(historySubscription.close);
    final initialHistory = app.container.read(
      historyEventsProvider(vehicleId).future,
    );
    await tester.pumpAndSettle();
    await initialHistory;

    await tester.tap(find.byKey(const ValueKey('chat_message_action')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Edited chat refueling',
    );
    final saveButton = find.widgetWithText(ElevatedButton, 'Save changes');
    await tester.dragUntilVisible(
      saveButton,
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(
      app.router.routeInformationProvider.value.uri.path,
      '/vehicle/$vehicleId/chat',
    );
    final refreshedEvents = await app.container.read(
      historyEventsProvider(vehicleId).future,
    );
    expect(historyDatasource.getCalls, 2);
    expect(
      refreshedEvents.firstWhere((event) => event.id == 'fuel_1').title,
      'Edited chat refueling',
    );
  });

  testWidgets('chat incomplete-event action opens a prefilled form', (
    tester,
  ) async {
    const vehicleId = '096c10bb-13d1-4599-9109-e9e79789ea88';
    final app = await _pumpApp(
      tester,
      initialLocation: '/vehicle/$vehicleId/chat',
      chatRepository: const _ActionChatRepository(
        type: 'OPEN_FORM',
        form: 'TRIP',
        prefill: {
          'title': 'City trip',
          'startMileageKm': 124580,
          'distanceKm': 50,
          'durationMinutes': 45,
        },
      ),
    );

    await tester.tap(find.byKey(const ValueKey('chat_message_action')));
    await tester.pumpAndSettle();

    expect(
      app.router.routeInformationProvider.value.uri.path,
      '/vehicle/$vehicleId/history/add',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('event-title')))
          .controller
          ?.text,
      'City trip',
    );
    expect(_formFieldText(tester, 'trip-start'), '124580');
    expect(_formFieldText(tester, 'trip-end'), '124630');
    await tester.dragUntilVisible(
      find.byKey(const ValueKey('trip-duration')),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(_formFieldText(tester, 'trip-duration'), '45');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(
      app.router.routeInformationProvider.value.uri.path,
      '/vehicle/$vehicleId/chat',
    );
  });

  testWidgets('chat returns to the latest messages after closing event form', (
    tester,
  ) async {
    const vehicleId = '096c10bb-13d1-4599-9109-e9e79789ea88';
    final app = await _pumpApp(
      tester,
      initialLocation: '/vehicle/$vehicleId/chat',
      chatRepository: const _ActionChatRepository(
        type: 'OPEN_FORM',
        form: 'TRIP',
        messageCount: 24,
        prefill: {
          'title': 'City trip',
          'startMileageKm': 124580,
          'distanceKm': 50,
          'durationMinutes': 45,
        },
      ),
    );
    final action = find.byKey(const ValueKey('chat_message_action'));
    await tester.scrollUntilVisible(
      action,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(
      app.router.routeInformationProvider.value.uri.path,
      '/vehicle/$vehicleId/history/add',
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final messageList = tester.widget<ListView>(find.byType(ListView));
    final position = messageList.controller!.position;
    expect(position.pixels, closeTo(position.maxScrollExtent, 1));
  });

  testWidgets('missing history event returns with a notification', (
    tester,
  ) async {
    const vehicleId = '096c10bb-13d1-4599-9109-e9e79789ea88';
    final app = await _pumpApp(
      tester,
      initialLocation: '/vehicle/$vehicleId/chat',
      historyDatasource: _RecordingEditableHistoryDatasource(),
      chatRepository: const _ActionChatRepository(
        screen: 'HISTORY_EVENT_EDIT',
        prefill: {'eventId': 'missing-event', 'eventType': 'REFUEL'},
      ),
    );

    await tester.tap(find.byKey(const ValueKey('chat_message_action')));
    await tester.pumpAndSettle();

    expect(
      app.router.routeInformationProvider.value.uri.path,
      '/vehicle/$vehicleId/chat',
    );
    expect(find.text('Event was not found'), findsOneWidget);
  });

  testWidgets('history add route opens outside the tab shell', (tester) async {
    await _pumpApp(
      tester,
      initialLocation:
          '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/history/add',
    );

    expect(find.byType(AddHistoryEventScreen), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    final screen = tester.widget<AddHistoryEventScreen>(
      find.byType(AddHistoryEventScreen),
    );
    expect(screen.vehicleId, '096c10bb-13d1-4599-9109-e9e79789ea88');
    expect(screen.initialMileageKm, 0);
    final mileageField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const ValueKey('fuel-mileage')),
        matching: find.byType(TextFormField),
      ),
    );
    expect(mileageField.controller?.text, isEmpty);
  });

  testWidgets('history add route accepts type and mileage query parameters', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      initialLocation:
          '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/history/add?type=maintenance&mileageKm=130000',
    );

    final screen = tester.widget<AddHistoryEventScreen>(
      find.byType(AddHistoryEventScreen),
    );
    expect(screen.initialType, HistoryEventType.maintenance);
    expect(screen.initialMileageKm, 130000);
    expect(find.text('New maintenance'), findsOneWidget);
  });

  testWidgets('history add route fills fields from chat prefill', (
    tester,
  ) async {
    const vehicleId = '096c10bb-13d1-4599-9109-e9e79789ea88';
    final location = Uri(
      path: '/vehicle/$vehicleId/history/add',
      queryParameters: const {
        'type': 'fuel',
        'title': 'Highway refueling',
        'mileageKm': '130000',
        'liters': '42.5',
        'cost': '3000',
        'fuelName': '95 octane',
        'stationName': 'Test station',
      },
    ).toString();

    await _pumpApp(tester, initialLocation: location);

    String fieldText(String key) {
      return tester
              .widget<TextFormField>(
                find.descendant(
                  of: find.byKey(ValueKey(key)),
                  matching: find.byType(TextFormField),
                ),
              )
              .controller
              ?.text ??
          '';
    }

    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('event-title')))
          .controller
          ?.text,
      'Highway refueling',
    );
    expect(fieldText('fuel-mileage'), '130000');
    expect(fieldText('fuel-liters'), '42.5');
    expect(fieldText('fuel-cost'), '3000');
    expect(find.text('95 octane • Test station'), findsOneWidget);
  });

  testWidgets('history add route accepts part query parameter', (tester) async {
    await _pumpApp(
      tester,
      initialLocation:
          '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/history/add?type=part_replacement',
    );

    final screen = tester.widget<AddHistoryEventScreen>(
      find.byType(AddHistoryEventScreen),
    );
    expect(screen.initialType, HistoryEventType.part);
  });

  testWidgets('history add button opens the form and saves an event', (
    tester,
  ) async {
    final app = await _pumpApp(
      tester,
      initialLocation: '/vehicle/096c10bb-13d1-4599-9109-e9e79789ea88/history',
    );

    final fabFinder = find.widgetWithIcon(FloatingActionButton, Icons.add);
    tester.widget<FloatingActionButton>(fabFinder).onPressed?.call();
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
    final eventsFuture = app.container
        .read(historyRepositoryProvider)
        .getEvents('096c10bb-13d1-4599-9109-e9e79789ea88');
    await tester.pump(const Duration(milliseconds: 600));
    final events = await eventsFuture;
    expect(events.any((event) => event.title == 'Highway refueling'), isTrue);
    expect(find.text('Highway refueling'), findsOneWidget);
  });

  testWidgets('saving a history event refreshes mileage for the next event', (
    tester,
  ) async {
    const vehicleId = '096c10bb-13d1-4599-9109-e9e79789ea88';
    final garageDatasource = _MileageGarageDatasource(
      vehicleId: vehicleId,
      mileageKm: 124000,
    );
    final historyDatasource = _MileageUpdatingHistoryDatasource(
      garageDatasource: garageDatasource,
    );

    await _pumpApp(
      tester,
      initialLocation: '/vehicle/$vehicleId/history',
      garageDatasource: garageDatasource,
      historyDatasource: historyDatasource,
    );

    await tester.tap(find.byTooltip('Add event'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Mileage refresh fuel stop',
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
    tester.widget<ElevatedButton>(saveButton).onPressed?.call();
    await tester.pumpAndSettle();

    final addEventFab = find.widgetWithIcon(FloatingActionButton, Icons.add);
    tester.widget<FloatingActionButton>(addEventFab).onPressed?.call();
    await tester.pumpAndSettle();

    final screen = tester.widget<AddHistoryEventScreen>(
      find.byType(AddHistoryEventScreen),
    );
    expect(screen.initialMileageKm, 124600);
    final mileageField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const ValueKey('fuel-mileage')),
        matching: find.byType(TextFormField),
      ),
    );
    expect(mileageField.controller?.text, '124600');
  });
}

Future<_TestApp> _pumpApp(
  WidgetTester tester, {
  String? initialLocation,
  AuthRepository authRepository = const _AuthenticatedRepository(),
  ChatRepository? chatRepository,
  GarageDatasource? garageDatasource,
  HistoryDatasource? historyDatasource,
  LiveTripRepository liveTripRepository = const _EmptyLiveTripRepository(),
  bool settle = true,
}) async {
  final resolvedGarageDatasource =
      garageDatasource ?? InMemoryGarageDatasource();
  final resolvedHistoryDatasource =
      historyDatasource ?? MockHistoryDatasource(delay: Duration.zero);
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepository),
      if (chatRepository != null)
        chatRepositoryProvider.overrideWithValue(chatRepository),
      garageDatasourceProvider.overrideWithValue(resolvedGarageDatasource),
      historyDatasourceProvider.overrideWithValue(resolvedHistoryDatasource),
      liveTripRepositoryProvider.overrideWithValue(liveTripRepository),
      historyPhotoReaderProvider.overrideWithValue(null),
      vehicleDashboardProvider.overrideWith((ref, vehicleId) {
        return _dashboardData(vehicleId);
      }),
      analyticsSummaryProvider.overrideWith((ref, request) {
        return _analyticsSummary(request.period);
      }),
      vehiclePartsProvider.overrideWith((ref, vehicleId) {
        return const <VehiclePart>[];
      }),
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

  if (settle) {
    await tester.pumpAndSettle();
  }
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

String _formFieldText(WidgetTester tester, String key) {
  return tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(ValueKey(key)),
              matching: find.byType(TextFormField),
            ),
          )
          .controller
          ?.text ??
      '';
}

final class _TestApp {
  const _TestApp(this.router, this.container);

  final GoRouter router;
  final ProviderContainer container;
}

base class _EmptyLiveTripRepository implements LiveTripRepository {
  const _EmptyLiveTripRepository();

  @override
  Future<void> end() async {}

  @override
  Future<LiveTripSession?> restore() async => null;

  @override
  Future<void> start(LiveTripSession session) async {}
}

final class _RecordingLiveTripRepository extends _EmptyLiveTripRepository {
  int restoreCalls = 0;

  @override
  Future<LiveTripSession?> restore() async {
    restoreCalls++;
    return null;
  }
}

final class _ActionChatRepository implements ChatRepository {
  const _ActionChatRepository({
    this.type = 'OPEN_SCREEN',
    this.form,
    this.screen,
    this.messageCount = 1,
    this.prefill = const {},
  });

  final String type;
  final String? form;
  final String? screen;
  final int messageCount;
  final Map<String, Object?> prefill;

  @override
  Future<ChatState> getState(String vehicleId) async {
    return ChatState(
      sessionId: 'chat-session',
      quickQuestions: const [],
      messages: [
        for (var index = 0; index < messageCount; index++)
          ChatMessage(
            id: 'message_$index',
            role: ChatMessageRole.assistant,
            text: 'Chat message ${index + 1}',
            createdAt: DateTime(2026, 6, 22, 10, 15 + index),
            action: index == messageCount - 1
                ? ChatAction(
                    type: type,
                    form: form,
                    screen: screen,
                    prefill: prefill,
                  )
                : null,
          ),
      ],
    );
  }

  @override
  Future<SendMessageResult> sendMessage({
    required String vehicleId,
    required String text,
  }) {
    throw UnimplementedError();
  }
}

final class _RecordingEditableHistoryDatasource implements HistoryDatasource {
  _RecordingEditableHistoryDatasource([HistoryEvent? event])
    : _events = [?event];

  final List<HistoryEvent> _events;
  int getCalls = 0;

  @override
  Future<List<HistoryEvent>> getEvents(String vehicleId) async {
    getCalls++;
    return List.unmodifiable(_events);
  }

  @override
  Future<String> addEvent(HistoryEvent event) async {
    _events.add(event);
    return event.id;
  }

  @override
  Future<void> updateEvent(HistoryEvent event) async {
    final index = _events.indexWhere((item) => item.id == event.id);
    if (index == -1) throw StateError('Event not found');
    _events[index] = event;
  }

  @override
  Future<void> deleteEvent(String vehicleId, String eventId) async {
    _events.removeWhere((event) => event.id == eventId);
  }
}

_RecordingEditableHistoryDatasource _editableHistoryDatasource(
  String vehicleId, {
  bool isRecharge = false,
}) {
  return _RecordingEditableHistoryDatasource(
    HistoryEvent(
      id: 'fuel_1',
      carId: vehicleId,
      type: HistoryEventType.fuel,
      occurredAt: DateTime(2026, 6, 15, 14, 30),
      title: 'Refueling AI-95',
      currentMileageKm: 124580,
      details: FuelDetails(
        cost: 2450,
        liters: 45,
        fuelType: isRecharge ? 'AC charging' : '95 octane',
        isRecharge: isRecharge,
      ),
    ),
  );
}

final class _MileageGarageDatasource implements GarageDatasource {
  _MileageGarageDatasource({required this.vehicleId, required this.mileageKm});

  final String vehicleId;
  int mileageKm;

  @override
  Future<List<String>> getVehicleBrands() async {
    return const ['Lada'];
  }

  @override
  Future<List<Vehicle>> getVehicles() async {
    return [_vehicle(vehicleId).copyWith(currentMileageKm: mileageKm)];
  }

  @override
  Future<Vehicle> addVehicle(VehicleDraft draft) {
    throw UnimplementedError();
  }

  @override
  Future<Vehicle> updateVehicle(String vehicleId, VehicleDraft draft) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteVehicle(String vehicleId) {
    throw UnimplementedError();
  }
}

final class _MileageUpdatingHistoryDatasource implements HistoryDatasource {
  _MileageUpdatingHistoryDatasource({required this.garageDatasource});

  final _MileageGarageDatasource garageDatasource;
  final List<HistoryEvent> _events = [];

  @override
  Future<List<HistoryEvent>> getEvents(String vehicleId) async {
    return List.unmodifiable(_events);
  }

  @override
  Future<String> addEvent(HistoryEvent event) async {
    _events.add(event);
    garageDatasource.mileageKm = event.currentMileageKm;
    return event.id;
  }

  @override
  Future<void> updateEvent(HistoryEvent event) async {
    final index = _events.indexWhere((existing) => existing.id == event.id);
    if (index != -1) {
      _events[index] = event;
    }
  }

  @override
  Future<void> deleteEvent(String vehicleId, String eventId) async {
    _events.removeWhere((event) => event.id == eventId);
  }
}

DashboardData _dashboardData(String vehicleId) {
  return DashboardData(
    vehicle: _vehicle(vehicleId),
    maintenanceParts: const [],
    recentEvents: [
      DashboardRecentEvent(
        id: 'event_1',
        type: HistoryEventType.maintenance,
        title: 'Oil change',
        subtitle: 'Today',
        occurredAt: DateTime(2026, 6, 28),
      ),
    ],
  );
}

AnalyticsSummary _analyticsSummary(AnalyticsPeriod period) {
  return AnalyticsSummary(
    period: period,
    hasEnoughData: false,
    totalExpenses: null,
    expensesByCategory: const [],
    mileage: null,
    fuel: null,
    repairs: null,
    maintenanceForecast: null,
    history: null,
    charts: null,
    trendPercent: null,
    message: 'Not enough data for analytics yet.',
  );
}

Vehicle _vehicle(String vehicleId) {
  return Vehicle(
    id: vehicleId,
    brand: 'Lada',
    model: '2106',
    year: 2002,
    currentMileageKm: 124000,
    engineType: 'gasoline',
    engineVolumeLiters: 1.6,
    enginePowerHp: null,
    status: 'ok',
    activeWarningsCount: 0,
  );
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

final class _UnauthenticatedRepository implements AuthRepository {
  const _UnauthenticatedRepository();

  @override
  Future<AuthSession?> restoreSession() async {
    return null;
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

final class _HangingAuthRepository implements AuthRepository {
  const _HangingAuthRepository();

  @override
  Future<AuthSession?> restoreSession() {
    return Completer<AuthSession?>().future;
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
