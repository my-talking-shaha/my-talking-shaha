import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/history/presentation/screens/add_history_event_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  testWidgets('validates mileage and creates a fuel event', (tester) async {
    HistoryEvent? savedEvent;
    await _pumpScreen(tester, onSave: (event) async => savedEvent = event);

    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Evening fuel stop',
    );
    await tester.enterText(
      find.byKey(const ValueKey('fuel-mileage')),
      '124000',
    );
    await tester.enterText(find.byKey(const ValueKey('fuel-liters')), '42');
    await tester.enterText(find.byKey(const ValueKey('fuel-cost')), '3000');
    await _tapSave(tester);

    expect(savedEvent, isNull);
    expect(find.text('Must be at least 124580 km'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('fuel-mileage')),
      '124600',
    );
    await _tapSave(tester);

    expect(savedEvent?.carId, 'vehicle_1');
    expect(savedEvent?.title, 'Evening fuel stop');
    expect(savedEvent?.currentMileageKm, 124600);
    expect(savedEvent?.details, isA<FuelDetails>());
    expect((savedEvent?.details as FuelDetails).liters, 42);

    final amountDecoration = tester.widget<InputDecorator>(
      find.descendant(
        of: find.byKey(const ValueKey('fuel-liters')),
        matching: find.byType(InputDecorator),
      ),
    );
    expect(amountDecoration.decoration.labelText, isNull);
    expect(find.text('AMOUNT'), findsOneWidget);
  });

  testWidgets('validates fuel amount range and accepts decimal liters', (
    tester,
  ) async {
    HistoryEvent? savedEvent;
    await _pumpScreen(tester, onSave: (event) async => savedEvent = event);

    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Decimal fuel stop',
    );
    await tester.enterText(
      find.byKey(const ValueKey('fuel-mileage')),
      '124600',
    );
    await tester.enterText(find.byKey(const ValueKey('fuel-liters')), '150');
    await tester.enterText(find.byKey(const ValueKey('fuel-cost')), '3000');
    await _tapSave(tester);

    expect(savedEvent, isNull);
    expect(find.text('Max 100 L'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('fuel-liters')), '42.5');
    await _tapSave(tester);

    final details = savedEvent?.details as FuelDetails;
    expect(details.liters, 42.5);
  });

  testWidgets('fuel type dropdown uses the light theme palette', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      theme: AppTheme.light,
      onSave: (_) async {},
    );

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byWidgetPredicate((widget) => widget is DropdownButton<String>),
    );
    expect(dropdown.dropdownColor, AppPalette.light.surfaceHigh);
    expect(dropdown.iconEnabledColor, AppPalette.light.primaryLight);
    expect(dropdown.style?.color, AppPalette.light.textPrimary);
  });

  testWidgets('uses recharge labels for electric vehicle fuel events', (
    tester,
  ) async {
    HistoryEvent? savedEvent;
    await _pumpScreen(
      tester,
      isElectricVehicle: true,
      onSave: (event) async => savedEvent = event,
    );

    expect(find.text('New recharge'), findsOneWidget);
    expect(find.text('RECHARGE DETAILS'), findsOneWidget);
    expect(find.text('ENERGY'), findsOneWidget);
    expect(find.text('CHARGER TYPE'), findsOneWidget);
    expect(find.text('AC charging'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Evening recharge',
    );
    await tester.enterText(
      find.byKey(const ValueKey('fuel-mileage')),
      '124600',
    );
    await tester.enterText(find.byKey(const ValueKey('fuel-liters')), '0');
    await tester.enterText(find.byKey(const ValueKey('fuel-cost')), '3000');
    await _tapSave(tester);

    expect(savedEvent, isNull);
    expect(find.text('Must be > 0 kWh'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('fuel-liters')), '37.5');
    await _tapSave(tester);

    final details = savedEvent?.details as FuelDetails;
    expect(savedEvent?.title, 'Evening recharge');
    expect(details.liters, 37.5);
    expect(details.fuelType, 'AC charging');
    expect(details.isRecharge, isTrue);
  });

  testWidgets('blocks unrealistic recharge values', (tester) async {
    HistoryEvent? savedEvent;
    await _pumpScreen(
      tester,
      isElectricVehicle: true,
      onSave: (event) async => savedEvent = event,
    );

    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Impossible recharge',
    );
    await tester.enterText(
      find.byKey(const ValueKey('fuel-mileage')),
      '124600',
    );
    await tester.enterText(
      find.byKey(const ValueKey('fuel-liters')),
      '100000000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('fuel-cost')),
      '100000000',
    );
    await _tapSave(tester);

    expect(savedEvent, isNull);
    expect(find.text('Max 500 kWh'), findsOneWidget);
    expect(find.text('Max 100 000'), findsOneWidget);
  });

  testWidgets('localizes fuel amount validation errors', (tester) async {
    await _pumpScreen(tester, locale: const Locale('ru'), onSave: (_) async {});

    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Заправка',
    );
    await tester.enterText(
      find.byKey(const ValueKey('fuel-mileage')),
      '124600',
    );
    await tester.enterText(find.byKey(const ValueKey('fuel-liters')), '0');
    await tester.enterText(find.byKey(const ValueKey('fuel-cost')), '3000');
    await _tapSave(tester, label: 'Сохранить');

    expect(find.text('Больше 0 л'), findsOneWidget);
  });

  testWidgets('switches between maintenance and trip forms', (tester) async {
    await _pumpScreen(tester, onSave: (_) async {});

    var selection = tester.widget<AnimatedAlign>(
      find.byKey(const ValueKey('event-type-selection')),
    );
    expect(selection.alignment, Alignment.centerLeft);
    expect(selection.duration, const Duration(milliseconds: 320));

    await tester.tap(find.byKey(const ValueKey('event-type-maintenance')));
    await tester.pump();

    selection = tester.widget<AnimatedAlign>(
      find.byKey(const ValueKey('event-type-selection')),
    );
    expect(selection.alignment, Alignment.center);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('maintenance-description')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('event-type-trip')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('trip-start')), findsOneWidget);
    expect(find.byKey(const ValueKey('trip-end')), findsOneWidget);
  });

  testWidgets('selects and persists multiple maintenance photos', (
    tester,
  ) async {
    HistoryEvent? savedEvent;
    final persistedSourcePaths = <String>[];
    await _pumpScreen(
      tester,
      onSave: (event) async => savedEvent = event,
      pickPhotos: () async => [
        XFile('/tmp/selected-photo-1.jpg'),
        XFile('/tmp/selected-photo-2.jpg'),
      ],
      persistPhoto: ({
        required sourcePath,
        required originalName,
        required eventId,
      }) async {
        persistedSourcePaths.add(sourcePath);
        return '/documents/history_photos/$eventId/${sourcePath.split('/').last}';
      },
    );

    await tester.tap(find.byKey(const ValueKey('event-type-maintenance')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Oil service',
    );
    await tester.enterText(
      find.byKey(const ValueKey('maintenance-description')),
      'Changed oil and filter',
    );

    final addPhotoButton = find.byKey(const ValueKey('maintenance-photo-add'));
    await tester.dragUntilVisible(
      addPhotoButton,
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(addPhotoButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('maintenance-photo-preview-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('maintenance-photo-preview-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('maintenance-photo-remove-0')),
      findsOneWidget,
    );
    final photoList = tester.widget<ListView>(
      find.descendant(
        of: find.byKey(const ValueKey('maintenance-photo-list')),
        matching: find.byType(ListView),
      ),
    );
    expect(photoList.scrollDirection, Axis.horizontal);

    await _tapSave(tester);

    expect(persistedSourcePaths, [
      '/tmp/selected-photo-1.jpg',
      '/tmp/selected-photo-2.jpg',
    ]);
    final details = savedEvent?.details as MaintenanceDetails;
    expect(details.photoUrls, hasLength(2));
    expect(details.photoUrls?.first, startsWith('/documents/history_photos/'));
  });

  testWidgets('prefills existing event and saves changes with same id', (
    tester,
  ) async {
    HistoryEvent? savedEvent;
    final initialEvent = HistoryEvent(
      id: 'fuel_1',
      carId: 'vehicle_1',
      type: HistoryEventType.fuel,
      occurredAt: DateTime(2026, 6, 15, 14, 30),
      title: 'Refueling AI-95',
      currentMileageKm: 124580,
      details: FuelDetails(cost: 2450, liters: 45, fuelType: 'AI-95'),
    );

    await _pumpScreen(
      tester,
      initialEvent: initialEvent,
      onSave: (event) async => savedEvent = event,
    );

    expect(find.text('Edit refueling'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('event-title')))
          .controller
          ?.text,
      'Refueling AI-95',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('fuel-mileage')),
              matching: find.byType(TextFormField),
            ),
          )
          .controller
          ?.text,
      '124580',
    );
    expect(find.text('AI-95'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Updated fuel stop',
    );
    await _tapSave(tester, label: 'Save changes');

    expect(savedEvent?.id, 'fuel_1');
    expect(savedEvent?.title, 'Updated fuel stop');
    expect(savedEvent?.occurredAt, DateTime(2026, 6, 15, 14, 30));
    expect((savedEvent?.details as FuelDetails).fuelType, 'AI-95');
  });

  testWidgets('localizes electric edit title and max validators', (
    tester,
  ) async {
    HistoryEvent? savedEvent;
    final initialEvent = HistoryEvent(
      id: 'recharge_1',
      carId: 'vehicle_1',
      type: HistoryEventType.fuel,
      occurredAt: DateTime(2026, 6, 15, 14, 30),
      title: 'Evening recharge',
      currentMileageKm: 124580,
      details: FuelDetails(
        cost: 1200,
        liters: 37.5,
        fuelType: 'AC charging',
        isRecharge: true,
      ),
    );

    await _pumpScreen(
      tester,
      locale: const Locale('ru'),
      initialEvent: initialEvent,
      isElectricVehicle: true,
      onSave: (event) async => savedEvent = event,
    );

    expect(find.text('Редактировать зарядку'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('fuel-liters')),
      '100000000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('fuel-cost')),
      '100000000',
    );
    await _tapSave(tester, label: 'Сохранить изменения');

    expect(savedEvent, isNull);
    expect(find.text('Макс. 500 кВт·ч'), findsOneWidget);
    expect(find.text('Макс. 100 000'), findsOneWidget);
  });

  testWidgets('allows saving an edited trip with its original start mileage', (
    tester,
  ) async {
    HistoryEvent? savedEvent;
    final initialEvent = HistoryEvent(
      id: 'trip_1',
      carId: 'vehicle_1',
      type: HistoryEventType.trip,
      occurredAt: DateTime(2026, 6, 1, 9, 15),
      title: 'Long-distance trip',
      currentMileageKm: 123600,
      details: const TripDetails(
        startKm: 123180,
        endKm: 123600,
        route: 'Moscow — Tula — Moscow',
        duration: Duration(hours: 7, minutes: 12),
      ),
    );

    await _pumpScreen(
      tester,
      initialEvent: initialEvent,
      onSave: (event) async => savedEvent = event,
    );

    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Updated trip',
    );
    await _tapSave(tester, label: 'Save changes');

    expect(savedEvent?.id, 'trip_1');
    expect(savedEvent?.title, 'Updated trip');
    final details = savedEvent?.details as TripDetails;
    expect(details.startKm, 123180);
    expect(details.endKm, 123600);
  });

  testWidgets('shows existing maintenance photos when editing a draft', (
    tester,
  ) async {
    HistoryEvent? savedEvent;
    final initialEvent = HistoryEvent(
      id: 'maintenance_1',
      carId: 'vehicle_1',
      type: HistoryEventType.maintenance,
      occurredAt: DateTime(2026, 6, 8, 11),
      title: 'Oil service',
      currentMileageKm: 124000,
      details: MaintenanceDetails(
        description: 'Oil and filter replacement',
        cost: 8900,
        photoUrls: const ['/tmp/existing-maintenance-photo.jpg'],
      ),
    );

    await _pumpScreen(
      tester,
      initialEvent: initialEvent,
      onSave: (event) async => savedEvent = event,
    );

    final existingPhoto = find.byKey(
      const ValueKey('maintenance-existing-photo-preview-0'),
    );
    await tester.dragUntilVisible(
      existingPhoto,
      find.byType(ListView),
      const Offset(0, -300),
    );

    expect(existingPhoto, findsOneWidget);

    await _tapSave(tester, label: 'Save changes');

    final details = savedEvent?.details as MaintenanceDetails;
    expect(details.photoUrls, const ['/tmp/existing-maintenance-photo.jpg']);
  });

  testWidgets('removes existing maintenance photos from an edited draft', (
    tester,
  ) async {
    HistoryEvent? savedEvent;
    final deletedPhotoPaths = <String>[];
    final initialEvent = HistoryEvent(
      id: 'maintenance_1',
      carId: 'vehicle_1',
      type: HistoryEventType.maintenance,
      occurredAt: DateTime(2026, 6, 8, 11),
      title: 'Oil service',
      currentMileageKm: 124000,
      details: MaintenanceDetails(
        description: 'Oil and filter replacement',
        cost: 8900,
        photoUrls: const [
          '/tmp/existing-maintenance-photo.jpg',
          'https://example.invalid/remote-photo.jpg',
        ],
      ),
    );

    await _pumpScreen(
      tester,
      initialEvent: initialEvent,
      onSave: (event) async => savedEvent = event,
      deletePhoto: (path) async => deletedPhotoPaths.add(path),
    );

    final removePhoto = find.byKey(
      const ValueKey('maintenance-existing-photo-remove-0'),
    );
    await tester.dragUntilVisible(
      removePhoto,
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.tap(removePhoto);
    await tester.pump();

    await _tapSave(tester, label: 'Save changes');

    final details = savedEvent?.details as MaintenanceDetails;
    expect(details.photoUrls, const [
      'https://example.invalid/remote-photo.jpg',
    ]);
    expect(deletedPhotoPaths, const ['/tmp/existing-maintenance-photo.jpg']);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required SaveHistoryEvent onSave,
  PickHistoryPhoto? pickPhoto,
  PickHistoryPhotos? pickPhotos,
  PersistHistoryPhoto? persistPhoto,
  DeleteHistoryPhoto? deletePhoto,
  Locale locale = const Locale('en'),
  HistoryEvent? initialEvent,
  bool isElectricVehicle = false,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme ?? AppTheme.dark,
      home: AddHistoryEventScreen(
        vehicleId: 'vehicle_1',
        initialEvent: initialEvent,
        initialMileageKm: 124580,
        initialOccurredAt: DateTime(2026, 6, 20, 12),
        isElectricVehicle: isElectricVehicle,
        onSave: onSave,
        pickPhoto: pickPhoto,
        pickPhotos: pickPhotos,
        persistPhoto: persistPhoto ??
            ({
              required sourcePath,
              required originalName,
              required eventId,
            }) async =>
                sourcePath,
        deletePhoto: deletePhoto ?? (_) async {},
      ),
    ),
  );
  await tester.pump();
}

Future<void> _tapSave(WidgetTester tester, {String label = 'Save'}) async {
  final saveButton = find.widgetWithText(ElevatedButton, label);
  await tester.dragUntilVisible(
    saveButton,
    find.byType(ListView).first,
    const Offset(0, -520),
    maxIteration: 20,
  );
  tester.widget<ElevatedButton>(saveButton).onPressed?.call();
  await tester.pump();
}
