import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/di/history_providers.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/history/presentation/screens/add_history_event_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('hides maintenance photo actions on web', (tester) async {
    if (!kIsWeb) return;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: AddHistoryEventScreen(
          vehicleId: 'vehicle_1',
          initialMileageKm: 10000,
          initialOccurredAt: DateTime(2026, 6, 20, 12),
          onSave: (_) async {},
          persistPhoto:
              ({
                required sourcePath,
                required originalName,
                required eventId,
              }) => throw StateError('Web must not persist local photo files'),
          deletePhoto: (_) =>
              throw StateError('Web must not delete local photo files'),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('event-type-maintenance')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('maintenance-photo-add')), findsNothing);
    expect(
      find.byKey(const ValueKey('maintenance-photo-add-more')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('maintenance-photo-list')), findsNothing);
  });

  test('history photo providers avoid device file storage on web', () async {
    if (!kIsWeb) return;

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(historyPhotoReaderProvider), isNull);
    await expectLater(
      container.read(deleteHistoryPhotoCacheProvider)(_maintenanceEvent()),
      completes,
    );
  });
}

HistoryEvent _maintenanceEvent() {
  return HistoryEvent(
    id: 'maintenance_1',
    carId: 'vehicle_1',
    type: HistoryEventType.maintenance,
    occurredAt: DateTime.utc(2026, 6, 12, 16, 30),
    title: 'Oil change',
    currentMileageKm: 10000,
    details: MaintenanceDetails(
      description: 'Oil and filter replacement',
      photoUrls: const ['https://api.example.com/api/v1/photos/photo_1'],
    ),
  );
}
