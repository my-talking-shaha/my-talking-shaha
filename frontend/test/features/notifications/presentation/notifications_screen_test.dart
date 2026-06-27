import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';
import 'package:frontend/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:frontend/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:frontend/features/notifications/presentation/screens/notifications_screen.dart';

void main() {
  testWidgets('notifications screen renders network error state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(
            _FakeNotificationsRepository(error: Exception('network')),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const NotificationsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Network error'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('notifications_retry_action')),
      findsOneWidget,
    );
  });
}

final class _FakeNotificationsRepository implements NotificationsRepository {
  const _FakeNotificationsRepository({this.error});

  final Object? error;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final error = this.error;
    if (error != null) throw error;

    return const [];
  }
}
