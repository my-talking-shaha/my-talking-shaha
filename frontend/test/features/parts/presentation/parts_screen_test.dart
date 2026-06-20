import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/domain/repositories/parts_repository.dart';
import 'package:frontend/features/parts/presentation/providers/parts_providers.dart';
import 'package:frontend/features/parts/presentation/screens/parts_screen.dart';
import 'package:frontend/features/parts/presentation/widgets/maintenance_forecast_card.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('maintenance forecast card renders reusable resource rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: MaintenanceForecastCard(parts: _mockParts())),
      ),
    );

    expect(find.text('MAINTENANCE FORECAST'), findsOneWidget);
    expect(find.text('UPDATED 2 HOURS AGO'), findsOneWidget);
    expect(find.text('NEXT SERVICE'), findsOneWidget);
    expect(find.text('RESOURCE'), findsOneWidget);
    expect(find.text('Service needed now'), findsOneWidget);
    expect(find.text('Replace Battery now'), findsOneWidget);
    expect(find.text('In 800 km'), findsNothing);
    expect(find.text('Approx. date: in 16 days'), findsNothing);
    expect(find.text('19%'), findsOneWidget);
    expect(find.text('Engine oil'), findsOneWidget);
    expect(find.text('Front brake pads'), findsOneWidget);
    expect(find.text('Battery'), findsOneWidget);
    expect(find.text('Cabin filter'), findsOneWidget);
    expect(find.textContaining(RegExp(r'5\s?000|5,000')), findsOneWidget);
    expect(find.textContaining(RegExp(r'50\s?%')), findsWidgets);
    expect(find.textContaining(RegExp(r'8\s?%')), findsOneWidget);
    expect(find.text('0% · 0 km'), findsOneWidget);
    expect(find.text('Lifetime not set'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
  });

  testWidgets(
      'maintenance forecast uses nearest future resource without critical parts',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: MaintenanceForecastCard(parts: _mockPartsWithoutCritical()),
        ),
      ),
    );

    expect(find.text('In 800 km'), findsOneWidget);
    expect(find.text('Approx. date: in 16 days'), findsOneWidget);
    expect(find.text('Service needed now'), findsNothing);
  });

  testWidgets('parts screen shows loading while parts are requested', (
    tester,
  ) async {
    final pendingRequest = Completer<List<VehiclePart>>();
    final repository = _FakePartsRepository(
      pendingParts: pendingRequest.future,
    );

    await _pumpPartsRoute(tester, repository);

    expect(find.byKey(const ValueKey('parts_loading_state')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pendingRequest.complete(_mockParts());
  });

  testWidgets('parts screen loads mocked parts by vehicleId route parameter', (
    tester,
  ) async {
    final repository = _FakePartsRepository(
      partsByVehicle: {'vehicle_123': _mockParts()},
    );

    await _pumpPartsRoute(tester, repository);
    await tester.pumpAndSettle();

    expect(repository.requestedVehicleIds, ['vehicle_123']);
    expect(find.byType(MaintenanceForecastCard), findsOneWidget);
    expect(find.text('NEXT SERVICE'), findsOneWidget);
    expect(find.text('Engine oil'), findsOneWidget);
    expect(find.text('Lifetime not set'), findsOneWidget);
    expect(find.text('0% · 0 km'), findsOneWidget);
  });

  testWidgets('parts screen back action returns to garage', (tester) async {
    final repository = _FakePartsRepository(
      partsByVehicle: {'vehicle_123': _mockParts()},
    );

    await _pumpPartsRoute(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('garage route'), findsOneWidget);
  });

  testWidgets('parts screen renders empty and error states', (tester) async {
    await _pumpPartsRoute(tester, _FakePartsRepository());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('parts_empty_state')), findsOneWidget);

    await _pumpPartsRoute(
      tester,
      _FakePartsRepository(error: Exception('boom')),
      initialLocation: '/vehicle/vehicle_error/parts',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('parts_error_state')), findsOneWidget);
    expect(find.byKey(const ValueKey('parts_retry_action')), findsOneWidget);
  });
}

Future<void> _pumpPartsRoute(
  WidgetTester tester,
  _FakePartsRepository repository, {
  String initialLocation = '/vehicle/vehicle_123/parts',
}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/garage',
        builder: (context, state) => const Scaffold(body: Text('garage route')),
      ),
      GoRoute(
        path: '/vehicle/:vehicleId/parts',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId'] ?? '';

          return PartsScreen(vehicleId: vehicleId);
        },
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [partsRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    ),
  );
}

List<VehiclePart> _mockParts() {
  return [
    VehiclePart(
      id: 'part_engine_oil',
      vehicleId: 'vehicle_123',
      name: 'Engine oil',
      catalogKey: 'engine_oil',
      installedAt: DateTime.utc(2026, 6, 8, 11),
      installedAtMileageKm: 100000,
      lifetimeKm: 10000,
      remainingKm: 5000,
      remainingPercent: 50,
      status: PartResourceStatus.ok,
    ),
    VehiclePart(
      id: 'part_front_pads',
      vehicleId: 'vehicle_123',
      name: 'Front brake pads',
      catalogKey: 'brake_pads',
      installedAt: DateTime.utc(2026, 5, 20, 11),
      installedAtMileageKm: 100000,
      lifetimeKm: 10000,
      remainingKm: 800,
      remainingPercent: 8,
      status: PartResourceStatus.warning,
    ),
    VehiclePart(
      id: 'part_battery',
      vehicleId: 'vehicle_123',
      name: 'Battery',
      catalogKey: 'battery',
      installedAt: DateTime.utc(2025, 12, 1, 11),
      installedAtMileageKm: 100000,
      lifetimeKm: 10000,
      remainingKm: -1000,
      remainingPercent: -10,
      status: PartResourceStatus.critical,
    ),
    VehiclePart(
      id: 'part_cabin_filter',
      vehicleId: 'vehicle_123',
      name: 'Cabin filter',
      catalogKey: 'cabin_filter',
      installedAt: DateTime.utc(2026, 6, 1, 11),
      installedAtMileageKm: 100000,
      lifetimeKm: null,
      remainingKm: null,
      remainingPercent: null,
      status: PartResourceStatus.unknown,
    ),
  ];
}

List<VehiclePart> _mockPartsWithoutCritical() {
  return _mockParts()
      .where((part) => part.status != PartResourceStatus.critical)
      .toList(growable: false);
}

final class _FakePartsRepository implements PartsRepository {
  _FakePartsRepository({
    this.partsByVehicle = const {},
    this.pendingParts,
    this.error,
  });

  final Map<String, List<VehiclePart>> partsByVehicle;
  final Future<List<VehiclePart>>? pendingParts;
  final Object? error;
  final List<String> requestedVehicleIds = [];

  @override
  Future<List<VehiclePart>> getParts({required String vehicleId}) {
    requestedVehicleIds.add(vehicleId);

    final pendingParts = this.pendingParts;
    if (pendingParts != null) {
      return pendingParts;
    }

    final error = this.error;
    if (error != null) {
      return Future.error(error);
    }

    return Future.value(partsByVehicle[vehicleId] ?? const []);
  }
}
