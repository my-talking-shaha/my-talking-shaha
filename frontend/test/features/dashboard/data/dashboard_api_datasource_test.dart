import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/dashboard/data/datasources/dashboard_api_datasource.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';

void main() {
  group('DashboardApiEventMapper', () {
    test('maps backend recent event response to dashboard event', () {
      final event = DashboardApiEventMapper.fromJson(const {
        'id': 'event_1',
        'type': 'REFUEL',
        'title': 'Refueling AI-95',
        'subtitle': '32 L at 128,430 km',
        'eventDateTime': '2026-06-22T10:15:00Z',
      });

      expect(event.id, 'event_1');
      expect(event.type, HistoryEventType.fuel);
      expect(event.title, 'Refueling AI-95');
      expect(event.subtitle, '32 L at 128,430 km');
      expect(event.occurredAt.toUtc(), DateTime.utc(2026, 6, 22, 10, 15));
    });
  });
}
