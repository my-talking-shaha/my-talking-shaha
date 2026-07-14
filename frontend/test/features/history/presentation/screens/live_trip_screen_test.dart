import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/di/history_providers.dart';
import 'package:frontend/features/history/di/live_trip_providers.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';
import 'package:frontend/features/history/domain/repositories/live_trip_repository.dart';
import 'package:frontend/features/history/presentation/screens/live_trip_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('finishes an active trip and creates a history event', (
    tester,
  ) async {
    final startedAt = DateTime.now().subtract(const Duration(seconds: 75));
    final session = LiveTripSession(
      vehicleId: 'vehicle_1',
      vehicleName: 'Lada 2107',
      startMileageKm: 120000,
      startedAt: startedAt,
    );
    final liveTripRepository = _MemoryLiveTripRepository(session);
    HistoryEvent? savedEvent;
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (context, state) => const Scaffold(body: Text('History')),
        ),
        GoRoute(
          path: '/live',
          builder: (context, state) =>
              const LiveTripScreen(vehicleId: 'vehicle_1'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liveTripRepositoryProvider.overrideWithValue(liveTripRepository),
          addHistoryEventProvider.overrideWithValue((event) async {
            savedEvent = event;
          }),
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

    unawaited(router.push('/live'));
    await tester.pumpAndSettle();

    expect(find.text('Trip in progress'), findsOneWidget);
    expect(find.text('120000 km'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('finish-live-trip')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('live-trip-end-mileage')),
      '119999',
    );
    await tester.tap(find.byKey(const ValueKey('save-live-trip')));
    await tester.pump();

    expect(find.text('Must be at least 120000 km'), findsOneWidget);
    expect(savedEvent, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('live-trip-end-mileage')),
      '120015',
    );
    await tester.enterText(
      find.byKey(const ValueKey('live-trip-route')),
      'Home — Office',
    );
    await tester.tap(find.byKey(const ValueKey('save-live-trip')));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(liveTripRepository.session, isNull);
    expect(savedEvent?.currentMileageKm, 120015);
    final details = savedEvent?.details as TripDetails;
    expect(details.startKm, 120000);
    expect(details.route, 'Home — Office');
    expect(details.duration, const Duration(minutes: 2));
  });
}

final class _MemoryLiveTripRepository implements LiveTripRepository {
  _MemoryLiveTripRepository(this.session);

  LiveTripSession? session;

  @override
  Future<void> end() async => session = null;

  @override
  Future<LiveTripSession?> restore() async => session;

  @override
  Future<void> start(LiveTripSession value) async => session = value;
}
