import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/notifications/di/notifications_providers.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';
import 'package:frontend/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:frontend/features/notifications/presentation/screens/notification_details_screen.dart';
import 'package:frontend/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('renders notifications newest first without mutating on swipes', (
    tester,
  ) async {
    final repository = _RecordingNotificationsRepository(_notifications);
    await _pumpScreen(
      tester,
      const NotificationsScreen(),
      repository: repository,
    );

    expect(find.text('First notification'), findsOneWidget);
    expect(find.text('Second notification'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('First notification')).dy,
      lessThan(tester.getTopLeft(find.text('Second notification')).dy),
    );

    await tester.drag(find.byType(ListView), const Offset(-280, 0));
    await tester.pumpAndSettle();

    expect(find.text('First notification'), findsOneWidget);
    expect(find.text('Second notification'), findsOneWidget);
    expect(repository.calls, 1);
  });

  testWidgets('pull to refresh requests the notifications again', (
    tester,
  ) async {
    final repository = _RecordingNotificationsRepository(_notifications);
    await _pumpScreen(
      tester,
      const NotificationsScreen(),
      repository: repository,
    );

    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
  });

  testWidgets('details preserve date, message, resource and recommendation', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      const NotificationDetailsScreen(notificationId: 'first'),
      repository: _RecordingNotificationsRepository(_notifications),
    );

    expect(find.text('10.06.2026, 10:05'), findsOneWidget);
    expect(find.text('Full notification message'), findsOneWidget);
    expect(find.text('450 km'), findsOneWidget);
    expect(find.text('Schedule service'), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required NotificationsRepository repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final class _RecordingNotificationsRepository
    implements NotificationsRepository {
  _RecordingNotificationsRepository(this.notifications);

  final List<AppNotification> notifications;
  int calls = 0;

  @override
  Future<List<AppNotification>> getNotifications() async {
    calls++;
    return notifications;
  }
}

final _notifications = [
  AppNotification(
    id: 'first',
    title: 'First notification',
    description: 'Full notification message',
    createdAt: DateTime.utc(2026, 6, 10, 10, 5),
    type: AppNotificationType.partLifetimeWarning,
    read: false,
    remainingKm: 450,
    recommendedAction: 'Schedule service',
  ),
  AppNotification(
    id: 'second',
    title: 'Second notification',
    description: 'Second message',
    createdAt: DateTime.utc(2026, 6, 9, 9),
    type: AppNotificationType.system,
    read: true,
  ),
];
