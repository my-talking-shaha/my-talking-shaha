import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/data/datasources/mock_history_datasource.dart';
import 'package:frontend/features/history/presentation/providers/history_providers.dart';
import 'package:frontend/features/history/presentation/screens/history_screen.dart';

void main() {
  testWidgets('filters mock history by event type and search query', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mockHistoryDatasourceProvider.overrideWithValue(
            const MockHistoryDatasource(delay: Duration.zero),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const HistoryScreen(vehicleId: 'vehicle_1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('JUNE 2026'), findsOneWidget);
    expect(find.text('Refueling AI-95'), findsOneWidget);
    expect(find.text('Oil and filter change'), findsOneWidget);

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
}
