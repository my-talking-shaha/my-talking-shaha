import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/garage/domain/entities/garage_vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';
import 'package:frontend/features/garage/domain/repositories/garage_repository.dart';
import 'package:frontend/features/garage/presentation/providers/garage_providers.dart';
import 'package:frontend/features/garage/presentation/screens/add_vehicle_screen.dart';
import 'package:frontend/features/garage/presentation/screens/garage_screen.dart';
import 'package:frontend/features/garage/presentation/widgets/vehicle_garage_card.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('empty garage shows the add vehicle action', (tester) async {
    final repository = _FakeGarageRepository();

    await _pumpGarage(tester, repository);

    expect(find.text('Add vehicle'), findsOneWidget);

    await tester.tap(find.text('Add vehicle'));
    await tester.pumpAndSettle();

    expect(find.text('add vehicle route'), findsOneWidget);
  });

  testWidgets(
      'vehicle cards show garage data and navigate with vehicleId route parameter',
      (
    tester,
  ) async {
    final repository = _FakeGarageRepository(
      vehicles: [
        _vehicle(
          id: 'vehicle_123',
          brand: 'Lada',
          model: '2106',
          year: 1998,
          color: 'blue',
          currentMileageKm: 124580,
          engineType: 'gasoline',
        ),
      ],
    );

    await _pumpGarage(tester, repository);

    expect(find.textContaining('Lada'), findsOneWidget);
    expect(find.textContaining('2106'), findsOneWidget);
    expect(find.textContaining('1998'), findsOneWidget);
    expect(find.textContaining('blue'), findsOneWidget);
    expect(find.textContaining('gasoline'), findsOneWidget);
    expect(find.textContaining('124'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('garage_vehicle_photo_fallback_vehicle_123')),
        findsOneWidget);

    await tester.tap(find.textContaining('Lada'));
    await tester.pumpAndSettle();

    expect(find.text('chat:vehicle_123'), findsOneWidget);
  });

  testWidgets('swipe reveals edit and delete actions', (tester) async {
    final repository = _FakeGarageRepository(
      vehicles: [_vehicle(id: 'vehicle_123', brand: 'Lada', model: '2106')],
    );

    await _pumpGarage(tester, repository);

    await tester.drag(find.byType(VehicleGarageCard), const Offset(-160, 0));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('garage_swipe_action_edit')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('garage_swipe_action_delete')),
      findsOneWidget,
    );
  });

  testWidgets('edit action opens prefilled form and saves changes',
      (tester) async {
    final repository = _FakeGarageRepository(
      vehicles: [
        _vehicle(
          id: 'vehicle_123',
          brand: 'Lada',
          model: '2106',
          year: 1998,
          color: 'blue',
          currentMileageKm: 124580,
          engineType: 'gasoline',
        ),
      ],
    );

    await _pumpGarage(tester, repository);

    await tester.drag(find.byType(VehicleGarageCard), const Offset(-160, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('garage_swipe_action_edit')));
    await tester.pumpAndSettle();

    expect(find.text('Edit car'), findsOneWidget);
    final textFields = tester.widgetList<TextField>(find.byType(TextField));
    expect(textFields.elementAt(0).controller?.text, 'Lada');
    expect(textFields.elementAt(1).controller?.text, '2106');

    await tester.enterText(find.byType(TextField).at(1), '2107');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final vehicles = await repository.getVehicles();
    expect(vehicles.single.model, '2107');
    expect(find.textContaining('2107'), findsOneWidget);
  });

  testWidgets('delete action requires confirmation and supports cancel',
      (tester) async {
    final repository = _FakeGarageRepository(
      vehicles: [
        _vehicle(id: 'vehicle_123', brand: 'Lada', model: '2106'),
        _vehicle(id: 'vehicle_456', brand: 'Toyota', model: 'Prius'),
      ],
    );

    await _pumpGarage(tester, repository);

    await tester.drag(
        find.byType(VehicleGarageCard).first, const Offset(-160, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('garage_swipe_action_delete')));
    await tester.pumpAndSettle();

    expect(repository.deletedVehicleIds, isEmpty);
    expect(find.text('Delete vehicle?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.deletedVehicleIds, isEmpty);
    expect(find.textContaining('Lada'), findsOneWidget);

    await tester.drag(
        find.byType(VehicleGarageCard).first, const Offset(-160, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('garage_swipe_action_delete')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.deletedVehicleIds, ['vehicle_123']);
    expect(find.textContaining('Lada'), findsNothing);
    expect(find.textContaining('Toyota'), findsOneWidget);
  });
}

Future<void> _pumpGarage(
    WidgetTester tester, _FakeGarageRepository repository) async {
  final router = GoRouter(
    initialLocation: '/garage',
    routes: [
      GoRoute(
          path: '/garage', builder: (context, state) => const GarageScreen()),
      GoRoute(
        path: '/garage/add',
        builder: (context, state) =>
            const Scaffold(body: Text('add vehicle route')),
      ),
      GoRoute(
        path: '/garage/edit/:vehicleId',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId'] ?? '';
          return AddVehicleScreen(vehicleId: vehicleId);
        },
      ),
      GoRoute(
        path: '/vehicle/:vehicleId/chat',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId'];
          return Scaffold(body: Text('chat:$vehicleId'));
        },
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [garageRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

GarageVehicle _vehicle({
  required String id,
  required String brand,
  required String model,
  int year = 1998,
  String? color,
  int currentMileageKm = 0,
  String engineType = 'gasoline',
  String? photoUrl,
}) {
  return GarageVehicle(
    id: id,
    brand: brand,
    model: model,
    year: year,
    color: color,
    currentMileageKm: currentMileageKm,
    engineType: engineType,
    photoUrl: photoUrl,
    status: GarageVehicleStatus.unknown,
    activeWarningsCount: 0,
  );
}

final class _FakeGarageRepository implements GarageRepository {
  _FakeGarageRepository({List<GarageVehicle> vehicles = const []})
      : _vehicles = [...vehicles];

  final List<GarageVehicle> _vehicles;
  final List<String> deletedVehicleIds = [];

  @override
  Future<List<GarageVehicle>> getVehicles() async =>
      List.unmodifiable(_vehicles);

  @override
  Future<GarageVehicle> addVehicle(VehicleDraft draft) async {
    final vehicle = GarageVehicle(
      id: 'vehicle_${_vehicles.length + 1}',
      brand: draft.brand,
      model: draft.model,
      year: draft.year,
      color: draft.color,
      currentMileageKm: draft.currentMileageKm,
      engineType: draft.engineType,
      photoUrl: null,
      status: GarageVehicleStatus.unknown,
      activeWarningsCount: 0,
    );
    _vehicles.add(vehicle);
    return vehicle;
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    deletedVehicleIds.add(vehicleId);
    _vehicles.removeWhere((vehicle) => vehicle.id == vehicleId);
  }

  @override
  Future<GarageVehicle> updateVehicle(String vehicleId, VehicleDraft draft) {
    final index = _vehicles.indexWhere((vehicle) => vehicle.id == vehicleId);
    final vehicle = GarageVehicle(
      id: vehicleId,
      brand: draft.brand,
      model: draft.model,
      year: draft.year,
      color: draft.color,
      currentMileageKm: draft.currentMileageKm,
      engineType: draft.engineType,
      photoUrl: null,
      status: GarageVehicleStatus.unknown,
      activeWarningsCount: 0,
    );
    _vehicles[index] = vehicle;
    return Future.value(vehicle);
  }
}
