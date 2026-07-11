import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/history/presentation/widgets/event_card.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('fuel card shows details, formatted cost, date, and fuel icon', (
    tester,
  ) async {
    final event = HistoryEvent(
      id: 'fuel_1',
      carId: 'vehicle_1',
      type: HistoryEventType.fuel,
      occurredAt: DateTime(2026, 6, 15, 14, 30),
      title: 'Refueling AI-95',
      currentMileageKm: 124580,
      details: FuelDetails(cost: 2450, liters: 45, fuelType: 'AI-95'),
    );

    await _pumpCard(tester, event);

    expect(find.text('Refueling AI-95'), findsOneWidget);
    expect(find.text('45 L • AI-95'), findsOneWidget);
    expect(find.text('2 450 ₽'), findsOneWidget);
    expect(find.text('June 15, 14:30'), findsOneWidget);
    expect(_svgAssetName(tester), 'assets/icons/events/gas.svg');
  });

  testWidgets('charging fuel card uses charge icon', (tester) async {
    final event = HistoryEvent(
      id: 'charge_1',
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

    await _pumpCard(tester, event);

    expect(find.text('Evening recharge'), findsOneWidget);
    expect(find.text('37.5 kWh • AC charging'), findsOneWidget);
    expect(_svgAssetName(tester), 'assets/icons/events/charge.svg');
  });

  testWidgets(
    'maintenance card handles optional cost, parts, and photo fallback',
    (tester) async {
      final withoutOptionalValues = HistoryEvent(
        id: 'maintenance_1',
        carId: 'vehicle_1',
        type: HistoryEventType.maintenance,
        occurredAt: DateTime(2026, 6, 8, 11),
        title: 'Oil and filter change',
        currentMileageKm: 124000,
        details: MaintenanceDetails(
          description: 'Shell Helix Ultra 5W-40',
          replacedParts: ['Oil filter', 'Air filter'],
        ),
      );

      await _pumpCard(tester, withoutOptionalValues);

      expect(find.text('Shell Helix Ultra 5W-40'), findsOneWidget);
      expect(find.textContaining('Oil filter'), findsOneWidget);
      expect(find.textContaining('Air filter'), findsOneWidget);
      expect(find.textContaining('₽'), findsNothing);
      expect(_svgAssetName(tester), 'assets/icons/events/spanner.svg');

      final withPhoto = HistoryEvent(
        id: 'maintenance_2',
        carId: 'vehicle_1',
        type: HistoryEventType.maintenance,
        occurredAt: DateTime(2026, 6, 8, 11),
        title: 'Scheduled maintenance',
        currentMileageKm: 124000,
        details: MaintenanceDetails(
          description: 'Diagnostics and consumables replacement',
          cost: 8900,
          photoUrls: const [
            '',
            'https://example.invalid/maintenance-photo.jpg',
            'https://example.invalid/second-photo.jpg',
          ],
        ),
      );

      await _pumpCard(tester, withPhoto);

      expect(find.text('8 900 ₽'), findsOneWidget);
      expect(find.text('Part photo: 2'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(Image), findsNothing);

      await tester.tap(find.byType(EventCard));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('event-photo-list')), findsOneWidget);
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.scrollDirection, Axis.horizontal);
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(images, hasLength(2));
      expect(images.first.image, isA<NetworkImage>());
      expect(
        (images.first.image as NetworkImage).url,
        'https://example.invalid/maintenance-photo.jpg',
      );
      expect(images.first.fit, BoxFit.cover);
      expect(images.first.errorBuilder, isNotNull);

      await tester.tap(find.byKey(const ValueKey('event-photo-open-0')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('event-photo-preview')), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('event-photo-preview-close')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('event-photo-preview')), findsNothing);

      final withLocalPhoto = HistoryEvent(
        id: 'maintenance_3',
        carId: 'vehicle_1',
        type: HistoryEventType.maintenance,
        occurredAt: DateTime(2026, 6, 8, 11),
        title: 'Local photo',
        currentMileageKm: 124000,
        details: MaintenanceDetails(
          description: 'Local preview',
          photoUrls: const ['/tmp/maintenance-photo.jpg'],
        ),
      );

      await _pumpCard(tester, withLocalPhoto);
      await tester.tap(find.byType(EventCard));
      await tester.pumpAndSettle();

      final localImage = tester.widget<Image>(find.byType(Image));
      expect(localImage.image, isA<FileImage>());
    },
  );

  testWidgets('trip card formats route, duration, distance without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final event = HistoryEvent(
      id: 'trip_1',
      carId: 'vehicle_1',
      type: HistoryEventType.trip,
      occurredAt: DateTime(2026, 6, 1, 9, 15),
      title: 'A very long trip title that should wrap onto multiple lines',
      currentMileageKm: 124000,
      details: const TripDetails(
        startKm: 100000,
        endKm: 112000,
        route: 'Moscow — Tula — Moscow with an additional stop',
        duration: Duration(hours: 2, minutes: 7),
      ),
    );

    await _pumpCard(tester, event);

    expect(find.textContaining('Moscow — Tula — Moscow'), findsOneWidget);
    expect(find.textContaining('2 h 7 min'), findsOneWidget);
    expect(find.text('12 000 km'), findsOneWidget);
    expect(_svgAssetName(tester), 'assets/icons/events/trip.svg');
    expect(tester.takeException(), isNull);
  });

  testWidgets('swipe actions reveal edit then delete icon buttons', (
    tester,
  ) async {
    var edited = false;
    var deleted = false;
    final event = HistoryEvent(
      id: 'fuel_1',
      carId: 'vehicle_1',
      type: HistoryEventType.fuel,
      occurredAt: DateTime(2026, 6, 15, 14, 30),
      title: 'Refueling AI-95',
      currentMileageKm: 124580,
      details: FuelDetails(cost: 2450, liters: 45, fuelType: 'AI-95'),
    );

    await _pumpCard(
      tester,
      event,
      onEdit: () => edited = true,
      onDelete: () => deleted = true,
    );

    await tester.drag(find.text('Refueling AI-95'), const Offset(-160, 0));
    await tester.pumpAndSettle();

    final editButton = find.byKey(const ValueKey('history_swipe_action_edit'));
    final deleteButton = find.byKey(
      const ValueKey('history_swipe_action_delete'),
    );
    expect(editButton, findsOneWidget);
    expect(deleteButton, findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Delete'), findsNothing);

    final editCenter = tester.getCenter(editButton);
    final deleteCenter = tester.getCenter(deleteButton);
    expect(editCenter.dx, lessThan(deleteCenter.dx));

    await tester.tap(editButton);
    await tester.tap(deleteButton);

    expect(edited, isTrue);
    expect(deleted, isTrue);
  });
}

Future<void> _pumpCard(
  WidgetTester tester,
  HistoryEvent event, {
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.dark,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: EventCard(event: event, onEdit: onEdit, onDelete: onDelete),
        ),
      ),
    ),
  );
  await tester.pump();
}

String _svgAssetName(WidgetTester tester) {
  final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
  return (picture.bytesLoader as SvgAssetLoader).assetName;
}
