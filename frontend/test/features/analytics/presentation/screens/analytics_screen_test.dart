import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/data/datasources/mock_analytics_datasource.dart';
import 'package:frontend/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:frontend/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:frontend/features/parts/presentation/providers/parts_providers.dart';

void main() {
  testWidgets('renders mocked analytics dashboard and switches periods', (
    tester,
  ) async {
    await _pumpAnalyticsScreen(tester, vehicleId: 'vehicle_1');

    expect(find.text('Intelligence'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('342,500 ₽'), findsOneWidget);
    expect(find.text('ANNUAL EXPENSES'), findsOneWidget);
    expect(find.text('MAINTENANCE'), findsOneWidget);
    expect(find.text('FUEL'), findsOneWidget);
    expect(find.textContaining('Forecast'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('analytics-period-month')));
    await tester.pumpAndSettle();

    expect(find.text('15,650 ₽'), findsOneWidget);
    expect(find.text('MONTHLY EXPENSES'), findsWidgets);

    await tester.dragUntilVisible(
      find.text('HISTORY ANALYSIS'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('HISTORY ANALYSIS'), findsOneWidget);
  });

  testWidgets('renders analytics insufficient-data state', (tester) async {
    await _pumpAnalyticsScreen(tester, vehicleId: 'vehicle_empty');

    expect(find.text('Not enough data for analytics'), findsOneWidget);
    expect(find.text('Add trip'), findsOneWidget);
    expect(find.text('Add refueling'), findsOneWidget);
    expect(find.text('Add repair'), findsOneWidget);
  });
}

Future<void> _pumpAnalyticsScreen(
  WidgetTester tester, {
  required String vehicleId,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        analyticsDatasourceProvider.overrideWithValue(
          MockAnalyticsDatasource(delay: Duration.zero),
        ),
        vehiclePartsProvider(vehicleId).overrideWith((ref) async => const []),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: AnalyticsScreen(vehicleId: vehicleId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
