import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/domain/history_event_type.dart';
import 'package:frontend/features/history/presentation/utils/history_event_form_utils.dart';

void main() {
  test('validates mileage boundaries', () {
    expect(
      HistoryEventFormUtils.validateMileage('124000', minimumMileageKm: 124580),
      'Must be at least 124580 km',
    );
    expect(
      HistoryEventFormUtils.validateMileage('124580', minimumMileageKm: 124580),
      isNull,
    );
    expect(
      HistoryEventFormUtils.validateTripEnd('124580', startMileage: '124580'),
      'Must exceed start',
    );
  });

  test('formats and normalizes form values', () {
    expect(
      HistoryEventFormUtils.formatDateTime(DateTime(2026, 6, 20, 9, 5)),
      '20/06/2026, 09:05',
    );
    expect(HistoryEventFormUtils.parseCommaSeparated(' oil filter, , belt '), [
      'oil filter',
      'belt',
    ]);
    expect(HistoryEventFormUtils.trimToNull('   '), isNull);
    expect(HistoryEventFormUtils.titleFor(HistoryEventType.trip), 'New trip');
  });
}
