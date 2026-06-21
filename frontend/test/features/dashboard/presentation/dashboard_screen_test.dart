import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';

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
      vehicles: const [
        Vehicle(
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
      ],
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
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows unavailable state for an unknown vehicle', (tester) async {
    await _pumpDashboard(tester, vehicles: const []);

    expect(find.text('Vehicle not found'), findsOneWidget);
    expect(find.text('Open garage'), findsOneWidget);
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required List<Vehicle> vehicles,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        garageRepositoryProvider.overrideWithValue(
          _FakeGarageRepository(vehicles),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const DashboardScreen(vehicleId: 'vehicle_1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final class _FakeGarageRepository implements GarageRepository {
  const _FakeGarageRepository(this.vehicles);

  final List<Vehicle> vehicles;

  @override
  Future<List<Vehicle>> getVehicles() async => vehicles;

  @override
  Future<Vehicle> addVehicle(VehicleDraft draft) {
    throw UnsupportedError('Not used by dashboard tests');
  }

  @override
  Future<void> deleteVehicle(String vehicleId) {
    throw UnsupportedError('Not used by dashboard tests');
  }

  @override
  Future<Vehicle> updateVehicle(String vehicleId, VehicleDraft draft) {
    throw UnsupportedError('Not used by dashboard tests');
  }
}
