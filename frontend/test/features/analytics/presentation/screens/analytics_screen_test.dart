import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/data/datasources/mock_analytics_datasource.dart';
import 'package:frontend/features/analytics/di/analytics_providers.dart';
import 'package:frontend/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:frontend/features/parts/di/parts_providers.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/l10n/generated/app_localizations_ru.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('renders mocked analytics dashboard and switches periods', (
    tester,
  ) async {
    await _pumpAnalyticsScreen(tester, vehicleId: 'vehicle_1');

    expect(find.text('Intelligence'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('1,258,700 ₽'), findsOneWidget);
    expect(find.text('ANNUAL EXPENSES'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('analytics-custom-date-range')),
      findsOneWidget,
    );
    expect(find.text('MAINTENANCE'), findsOneWidget);
    expect(find.text('FUEL'), findsOneWidget);
    expect(find.textContaining('Forecast'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('analytics-period-month')));
    await tester.pumpAndSettle();

    expect(find.text('184,950 ₽'), findsOneWidget);
    expect(find.text('MONTHLY EXPENSES'), findsWidgets);

    await tester.dragUntilVisible(
      find.text('MILEAGE TREND'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('MILEAGE TREND'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('analytics-mileage-year-filter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('analytics-mileage-month-filter')),
      findsOneWidget,
    );
    expect(find.text('Accumulated mileage by month'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('analytics-mileage-month-filter')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('June').last);
    await tester.pumpAndSettle();

    expect(find.text('Accumulated mileage by day'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('HISTORY ANALYSIS'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('HISTORY ANALYSIS'), findsOneWidget);
  });

  testWidgets('localizes analytics chart labels', (tester) async {
    await _pumpAnalyticsScreen(
      tester,
      vehicleId: 'vehicle_1',
      locale: const Locale('ru'),
    );

    expect(find.text('Свой период'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('ДИНАМИКА ПРОБЕГА'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('ДИНАМИКА ПРОБЕГА'), findsOneWidget);
    expect(find.text('Накопленный пробег по месяцам'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('analytics-mileage-month-filter')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Все месяцы'), findsWidgets);
    expect(find.text('Июнь'), findsOneWidget);

    final ru = AppLocalizationsRu();
    expect(find.text(ru.historyAnalysis, skipOffstage: false), findsOneWidget);
    expect(find.text(ru.companyMetrics, skipOffstage: false), findsOneWidget);
    expect(find.text('Надежность', skipOffstage: false), findsOneWidget);
    expect(find.text('Эффективность', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Нагрузка обслуживания', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('preserves period selection and ignores horizontal swipes', (
    tester,
  ) async {
    await _pumpAnalyticsScreen(tester, vehicleId: 'vehicle_1');

    await tester.drag(find.byType(ListView), const Offset(-250, 0));
    await tester.pumpAndSettle();

    expect(find.text('1,258,700 ₽'), findsOneWidget);
    expect(find.text('ANNUAL EXPENSES'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('analytics-period-all')));
    await tester.pumpAndSettle();

    expect(find.text('4,862,200 ₽'), findsOneWidget);
    expect(find.text('ALL-TIME EXPENSES'), findsOneWidget);
  });

  testWidgets('cancelling custom range leaves the current request unchanged', (
    tester,
  ) async {
    await _pumpAnalyticsScreen(tester, vehicleId: 'vehicle_1');

    await tester.tap(find.byKey(const ValueKey('analytics-custom-date-range')));
    await tester.pumpAndSettle();

    expect(find.byType(DateRangePickerDialog), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('1,258,700 ₽'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('analytics-clear-date-range')),
      findsNothing,
    );
  });

  testWidgets('chat launch controls the analytics app bar', (tester) async {
    await _pumpAnalyticsScreen(
      tester,
      vehicleId: 'vehicle_1',
      launchedFromChat: true,
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byTooltip('Back to chat'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
  });

  testWidgets('renders analytics insufficient-data state', (tester) async {
    await _pumpAnalyticsScreen(tester, vehicleId: 'vehicle_empty');

    expect(find.text('Not enough data for analytics'), findsOneWidget);
    expect(find.text('Add trip'), findsOneWidget);
    expect(find.text('Add refueling'), findsOneWidget);
    expect(find.text('Add repair'), findsOneWidget);
  });

  testWidgets('empty-state actions navigate to add history event flows', (
    tester,
  ) async {
    await _pumpAnalyticsRouter(tester, vehicleId: 'vehicle_empty');

    await tester.tap(find.text('Add trip'));
    await tester.pumpAndSettle();
    expect(find.text('add:trip:vehicle_empty'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add refueling'));
    await tester.pumpAndSettle();
    expect(find.text('add:fuel:vehicle_empty'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add repair'));
    await tester.pumpAndSettle();
    expect(find.text('add:maintenance:vehicle_empty'), findsOneWidget);
  });
}

late GoRouter router;

Future<void> _pumpAnalyticsScreen(
  WidgetTester tester, {
  required String vehicleId,
  Locale locale = const Locale('en'),
  bool launchedFromChat = false,
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
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: AnalyticsScreen(
          vehicleId: vehicleId,
          launchedFromChat: launchedFromChat,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpAnalyticsRouter(
  WidgetTester tester, {
  required String vehicleId,
}) async {
  router = GoRouter(
    initialLocation: '/analytics',
    routes: [
      GoRoute(
        path: '/analytics',
        builder: (context, state) => AnalyticsScreen(vehicleId: vehicleId),
      ),
      GoRoute(
        path: '/vehicle/:vehicleId/history/add',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId'] ?? '';
          final type = state.uri.queryParameters['type'] ?? 'fuel';
          return Scaffold(body: Text('add:$type:$vehicleId'));
        },
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        analyticsDatasourceProvider.overrideWithValue(
          MockAnalyticsDatasource(delay: Duration.zero),
        ),
        vehiclePartsProvider(vehicleId).overrideWith((ref) async => const []),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
