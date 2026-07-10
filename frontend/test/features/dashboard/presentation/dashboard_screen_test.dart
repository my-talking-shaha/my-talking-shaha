import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/di/dashboard_providers.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('shows vehicle summary and latest events', (tester) async {
    String? copiedVin;
    final binaryMessenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    binaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
      methodCall,
    ) async {
      if (methodCall.method == 'Clipboard.setData') {
        final arguments = methodCall.arguments as Map<Object?, Object?>;
        copiedVin = arguments['text'] as String?;
      }
      return null;
    });
    addTearDown(
      () => binaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpDashboard(
      tester,
      dashboard: DashboardData(
        vehicle: const Vehicle(
          id: 'vehicle_1',
          brand: 'Lada',
          model: '2106',
          year: 1998,
          color: 'blue',
          currentMileageKm: 124580,
          engineType: 'gasoline',
          engineVolumeLiters: 1.6,
          enginePowerHp: null,
          vin: 'XTA21060012345678',
          status: 'ok',
          activeWarningsCount: 0,
        ),
        maintenanceParts: [
          VehiclePart(
            id: 'part_1',
            vehicleId: 'vehicle_1',
            name: 'Engine oil',
            catalogKey: 'engine_oil',
            installedAt: DateTime.utc(2026, 6, 1),
            installedAtMileageKm: 120000,
            lifetimeKm: 10000,
            remainingKm: 5420,
            remainingPercent: 54,
            status: PartResourceStatus.ok,
          ),
        ],
        recentEvents: [
          DashboardRecentEvent(
            id: 'event_1',
            type: HistoryEventType.fuel,
            title: 'Refueling AI-95',
            subtitle: '32 L at 124,580 km',
            occurredAt: DateTime.now(),
          ),
        ],
      ),
    );

    expect(find.text('My Shaha'), findsOneWidget);
    expect(find.text('Lada 2106'), findsOneWidget);
    expect(find.text('124,580'), findsOneWidget);
    expect(find.text('1.6 L'), findsOneWidget);
    expect(find.text('Gasoline'), findsOneWidget);
    expect(find.text('1998 • blue'), findsNothing);
    expect(find.text('XTA21060012345678'), findsOneWidget);
    await tester.tap(find.byTooltip('Copy VIN'));
    await tester.pump();
    expect(copiedVin, 'XTA21060012345678');
    expect(find.text('VIN copied'), findsOneWidget);
    expect(find.text('Refueling AI-95'), findsOneWidget);
    expect(find.text('Engine oil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows unavailable state when dashboard cannot load', (
    tester,
  ) async {
    await _pumpDashboard(tester, error: Exception('Vehicle not found'));

    expect(find.text('Could not load the dashboard'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('retry refreshes the same dashboard and renders recovered data', (
    tester,
  ) async {
    final repository = _RetryDashboardRepository();

    await _pumpDashboard(tester, repository: repository);

    expect(find.text('Could not load the dashboard'), findsOneWidget);
    final callsBeforeRetry = repository.callCount;
    repository.shouldFail = false;

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(repository.callCount, greaterThan(callsBeforeRetry));
    expect(find.text('Lada Niva'), findsOneWidget);
  });

  testWidgets('keeps empty optional values and engine fallback behavior', (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      dashboard: _dashboardWithEmptyOptionalValues(),
    );

    expect(find.text('Unknown'), findsOneWidget);
    expect(find.text('VIN unavailable'), findsWidgets);

    final copyButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.copy_outlined),
    );
    expect(copyButton.onPressed, isNull);

    await tester.scrollUntilVisible(find.text('No events yet'), 400);
    expect(find.text('No events yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  DashboardData? dashboard,
  Object? error,
  DashboardRepository? repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(
          repository ??
              _FakeDashboardRepository(dashboard: dashboard, error: error),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: const DashboardScreen(vehicleId: 'vehicle_1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

DashboardData _dashboardWithEmptyOptionalValues() {
  return const DashboardData(
    vehicle: Vehicle(
      id: 'vehicle_1',
      brand: 'Lada',
      model: 'Niva',
      year: 1998,
      currentMileageKm: 0,
      engineType: 'custom',
      engineVolumeLiters: null,
      enginePowerHp: null,
      vin: '   ',
      status: 'ok',
      activeWarningsCount: 0,
    ),
    maintenanceParts: [],
    recentEvents: [],
  );
}

final class _FakeDashboardRepository implements DashboardRepository {
  const _FakeDashboardRepository({this.dashboard, this.error});

  final DashboardData? dashboard;
  final Object? error;

  @override
  Future<DashboardData> getDashboard(String vehicleId) async {
    final error = this.error;
    if (error != null) throw error;

    final dashboard = this.dashboard;
    if (dashboard == null) {
      throw StateError('Dashboard data was not provided');
    }

    return dashboard;
  }
}

final class _RetryDashboardRepository implements DashboardRepository {
  int callCount = 0;
  bool shouldFail = true;

  @override
  Future<DashboardData> getDashboard(String vehicleId) async {
    callCount++;
    if (shouldFail) throw Exception('Temporary failure');
    return _dashboardWithEmptyOptionalValues();
  }
}
