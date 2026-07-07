import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/data/datasources/mock_history_datasource.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/presentation/providers/history_providers.dart';
import 'package:frontend/features/history/presentation/screens/history_screen.dart';
import 'package:frontend/features/history/presentation/widgets/event_card.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

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
    expect(find.byIcon(Icons.tune), findsNothing);

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

  testWidgets('deleting an event clears its cached photos', (tester) async {
    final datasource = MockHistoryDatasource(delay: Duration.zero);
    HistoryEvent? cacheDeletedFor;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyDatasourceProvider.overrideWithValue(datasource),
          historyPhotoReaderProvider.overrideWithValue(null),
          deleteHistoryPhotoCacheProvider.overrideWithValue((event) async {
            cacheDeletedFor = event;
          }),
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
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(cacheDeletedFor?.id, 'maintenance_1');
    expect(find.text('Oil and filter change'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
