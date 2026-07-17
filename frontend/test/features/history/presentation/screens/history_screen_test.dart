import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/providers/vehicle_mileage_provider.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/data/datasources/in_memory_garage_datasource.dart';
import 'package:frontend/features/garage/di/garage_providers.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/history/data/datasources/history_datasource.dart';
import 'package:frontend/features/history/data/datasources/mock_history_datasource.dart';
import 'package:frontend/features/history/di/history_providers.dart';
import 'package:frontend/features/history/di/live_trip_providers.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';
import 'package:frontend/features/history/domain/repositories/live_trip_repository.dart';
import 'package:frontend/features/history/presentation/screens/history_screen.dart';
import 'package:frontend/features/history/presentation/widgets/event_card.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('filters mock history by event type and search query', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyDatasourceProvider.overrideWithValue(
            MockHistoryDatasource(delay: Duration.zero),
          ),
          historyPhotoReaderProvider.overrideWithValue(null),
          vehicleEngineTypeProvider.overrideWith(
            (ref, vehicleId) async => 'gasoline',
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const HistoryScreen(vehicleId: 'vehicle_1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('JUNE 2026'), findsOneWidget);
    expect(find.text('Refueling AI-95'), findsOneWidget);
    expect(find.text('Oil and filter change'), findsOneWidget);
    expect(find.byTooltip('Add event'), findsOneWidget);
    expect(find.byTooltip('Start live trip'), findsOneWidget);
    final fabColumn = tester.widget<Column>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('live-trip-fab-icon')),
            matching: find.byType(Column),
          )
          .first,
    );
    expect(fabColumn.mainAxisSize, MainAxisSize.min);
    final tripIcon = tester.widget<SvgPicture>(
      find.byKey(const ValueKey('live-trip-fab-icon')),
    );
    expect(tripIcon.bytesLoader, isA<SvgAssetLoader>());
    expect(
      (tripIcon.bytesLoader as SvgAssetLoader).assetName,
      'assets/icons/events/trip.svg',
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('live-trip-fab'))).dy,
      lessThan(
        tester
            .getTopLeft(find.byKey(const ValueKey('add-history-event-fab')))
            .dy,
      ),
    );
    for (final key in ['live-trip-fab', 'add-history-event-fab']) {
      final fab = tester.widget<FloatingActionButton>(
        find.byKey(ValueKey(key)),
      );
      expect(fab.elevation, 0);
      expect(fab.focusElevation, 0);
      expect(fab.hoverElevation, 0);
      expect(fab.highlightElevation, 0);
      expect(fab.disabledElevation, 0);
    }
    expect(find.byIcon(Icons.tune), findsNothing);
    expect(find.text('FUEL'), findsOneWidget);
    expect(find.text('CHARGE'), findsNothing);

    final repairsButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'REPAIRS'),
    );
    expect(repairsButton.style?.splashFactory, NoSplash.splashFactory);
    expect(repairsButton.style?.animationDuration, Duration.zero);
    expect(
      repairsButton.style?.overlayColor?.resolve({WidgetState.pressed}),
      Colors.transparent,
    );

    await tester.tap(find.text('REPAIRS'));
    await tester.pump();

    expect(find.text('Refueling AI-95'), findsNothing);
    expect(find.text('Oil and filter change'), findsOneWidget);

    await tester.tap(find.text('ALL'));
    await tester.enterText(find.byType(TextField), 'Tula');
    await tester.pump();

    expect(find.text('Long-distance trip'), findsOneWidget);
    expect(find.text('Oil and filter change'), findsNothing);
  });

  testWidgets('shows charge filter for electric vehicles', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyDatasourceProvider.overrideWithValue(
            MockHistoryDatasource(delay: Duration.zero),
          ),
          historyPhotoReaderProvider.overrideWithValue(null),
          vehicleEngineTypeProvider.overrideWith(
            (ref, vehicleId) async => 'electric',
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const HistoryScreen(vehicleId: 'vehicle_1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CHARGE'), findsOneWidget);
    expect(find.text('FUEL'), findsNothing);

    await tester.tap(find.text('CHARGE'));
    await tester.pump();

    expect(find.text('Refueling AI-95'), findsOneWidget);
    expect(find.text('Oil and filter change'), findsNothing);
  });

  testWidgets('confirms before starting a live trip', (tester) async {
    final garageDatasource = InMemoryGarageDatasource();
    await garageDatasource.addVehicle(
      const VehicleDraft(
        brand: 'Lada',
        model: '2107',
        year: 2008,
        currentMileageKm: 12300,
        engineType: 'gasoline',
        engineVolumeLiters: 1.6,
        enginePowerHp: 74,
      ),
    );
    final liveTripRepository = _RecordingLiveTripRepository();
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (context, state) =>
              const HistoryScreen(vehicleId: 'vehicle_1'),
        ),
        GoRoute(
          path: '/vehicle/:vehicleId/history/live',
          builder: (context, state) =>
              const Scaffold(body: Text('Live trip opened')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          garageDatasourceProvider.overrideWithValue(garageDatasource),
          historyDatasourceProvider.overrideWithValue(
            MockHistoryDatasource(delay: Duration.zero),
          ),
          historyPhotoReaderProvider.overrideWithValue(null),
          vehicleEngineTypeProvider.overrideWith(
            (ref, vehicleId) async => 'gasoline',
          ),
          liveTripRepositoryProvider.overrideWithValue(liveTripRepository),
        ],
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

    await tester.tap(find.byKey(const ValueKey('live-trip-fab')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Start trip?'), findsOneWidget);
    expect(liveTripRepository.session, isNull);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(liveTripRepository.session, isNull);

    await tester.tap(find.byKey(const ValueKey('live-trip-fab')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Start live trip'));
    await tester.pumpAndSettle();

    expect(find.text('Live trip opened'), findsOneWidget);
    expect(liveTripRepository.session?.vehicleId, 'vehicle_1');
    expect(liveTripRepository.session?.vehicleName, 'Lada 2107');
    expect(liveTripRepository.session?.startMileageKm, 12300);
  });

  testWidgets('deleting an event clears backend event then cached photos', (
    tester,
  ) async {
    final deletionSteps = <String>[];
    final datasource = _TrackingHistoryDatasource(
      MockHistoryDatasource(delay: Duration.zero),
      deletionSteps,
    );
    HistoryEvent? cacheDeletedFor;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyDatasourceProvider.overrideWithValue(datasource),
          historyPhotoReaderProvider.overrideWithValue(null),
          deleteHistoryPhotoCacheProvider.overrideWithValue((event) async {
            deletionSteps.add('cache:${event.id}');
            cacheDeletedFor = event;
          }),
          vehicleEngineTypeProvider.overrideWith(
            (ref, vehicleId) async => 'gasoline',
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark.copyWith(platform: TargetPlatform.iOS),
          home: const HistoryScreen(vehicleId: 'vehicle_1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.text('Oil and filter change'),
      const Offset(-160, 0),
    );
    await tester.pumpAndSettle();
    final oilServiceCard = find.ancestor(
      of: find.text('Oil and filter change'),
      matching: find.byType(EventCard),
    );
    final deleteAction = find.descendant(
      of: oilServiceCard,
      matching: find.byKey(const ValueKey('history_swipe_action_delete')),
    );
    await tester.tap(deleteAction);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(cacheDeletedFor?.id, 'maintenance_1');
    expect(deletionSteps, const [
      'backend:vehicle_1:maintenance_1',
      'cache:maintenance_1',
    ]);
    expect(find.text('Oil and filter change'), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('returning from edit resets opened swipe actions', (
    tester,
  ) async {
    final datasource = MockHistoryDatasource(delay: Duration.zero);
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (context, state) =>
              const HistoryScreen(vehicleId: 'vehicle_1'),
        ),
        GoRoute(
          path: '/vehicle/:vehicleId/history/:eventId/edit',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Edit state'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyDatasourceProvider.overrideWithValue(datasource),
          historyPhotoReaderProvider.overrideWithValue(null),
          vehicleEngineTypeProvider.overrideWith(
            (ref, vehicleId) async => 'gasoline',
          ),
        ],
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

    expect(
      find.byKey(const ValueKey('history_event_maintenance_1_0')),
      findsOneWidget,
    );

    await tester.drag(
      find.text('Oil and filter change'),
      const Offset(-160, 0),
    );
    await tester.pumpAndSettle();

    final oilServiceCard = find.ancestor(
      of: find.text('Oil and filter change'),
      matching: find.byType(EventCard),
    );
    final editAction = find.descendant(
      of: oilServiceCard,
      matching: find.byKey(const ValueKey('history_swipe_action_edit')),
    );
    await tester.tap(editAction);
    await tester.pumpAndSettle();

    expect(find.text('Edit state'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('history_event_maintenance_1_1')),
      findsOneWidget,
    );
  });
}

final class _RecordingLiveTripRepository implements LiveTripRepository {
  LiveTripSession? session;

  @override
  Future<LiveTripSession?> restore() async => session;

  @override
  Future<void> start(LiveTripSession session) async {
    this.session = session;
  }

  @override
  Future<void> end() async {
    session = null;
  }
}

final class _TrackingHistoryDatasource implements HistoryDatasource {
  _TrackingHistoryDatasource(this.delegate, this.deletionSteps);

  final HistoryDatasource delegate;
  final List<String> deletionSteps;

  @override
  Future<List<HistoryEvent>> getEvents(String vehicleId) {
    return delegate.getEvents(vehicleId);
  }

  @override
  Future<String> addEvent(HistoryEvent event) {
    return delegate.addEvent(event);
  }

  @override
  Future<void> updateEvent(HistoryEvent event) {
    return delegate.updateEvent(event);
  }

  @override
  Future<void> deleteEvent(String vehicleId, String eventId) async {
    deletionSteps.add('backend:$vehicleId:$eventId');
    await delegate.deleteEvent(vehicleId, eventId);
  }
}
