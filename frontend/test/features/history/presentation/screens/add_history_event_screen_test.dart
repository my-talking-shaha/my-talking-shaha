import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/presentation/screens/add_history_event_screen.dart';
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

  testWidgets('selects and persists a maintenance photo', (tester) async {
    HistoryEvent? savedEvent;
    String? persistedSourcePath;
    await _pumpScreen(
      tester,
      onSave: (event) async => savedEvent = event,
      pickPhoto: () async => XFile('/tmp/selected-photo.jpg'),
      persistPhoto:
          ({
            required sourcePath,
            required originalName,
            required eventId,
          }) async {
            persistedSourcePath = sourcePath;
            return '/documents/history_photos/$eventId.jpg';
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
      find.byKey(const ValueKey('maintenance-photo-preview')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('maintenance-photo-remove')),
      findsOneWidget,
    );

    await _tapSave(tester);

    expect(persistedSourcePath, '/tmp/selected-photo.jpg');
    final details = savedEvent?.details as MaintenanceDetails;
    expect(details.photoUrls, hasLength(1));
    expect(details.photoUrls?.single, startsWith('/documents/history_photos/'));
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required SaveHistoryEvent onSave,
  PickHistoryPhoto? pickPhoto,
  PersistHistoryPhoto? persistPhoto,
  DeleteHistoryPhoto? deletePhoto,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: AddHistoryEventScreen(
        vehicleId: 'vehicle_1',
        initialMileageKm: 124580,
        initialOccurredAt: DateTime(2026, 6, 20, 12),
        onSave: onSave,
        pickPhoto: pickPhoto,
        persistPhoto:
            persistPhoto ??
            ({
              required sourcePath,
              required originalName,
              required eventId,
            }) async => sourcePath,
        deletePhoto: deletePhoto ?? (_) async {},
      ),
    ),
  );
  await tester.pump();
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.widgetWithText(ElevatedButton, 'Save');
  await tester.dragUntilVisible(
    saveButton,
    find.byType(ListView),
    const Offset(0, -300),
  );
  await tester.tap(saveButton);
  await tester.pump();
}
