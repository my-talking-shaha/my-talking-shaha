import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/presentation/state/history_event_form_prefill.dart';

void main() {
  test('maps maintenance and trip chat fields into typed prefill', () {
    final prefill = HistoryEventFormPrefill.fromQueryParameters(const {
      'part': 'Oil filter',
      'mileageKm': '15000.0',
      'currentMileageKm': '16000',
      'cost': '1200',
      'repairText': 'Filter replacement',
      'replacedParts': 'Oil filter, engine oil',
      'startMileageKm': '16000',
      'distanceKm': '42',
      'durationMinutes': '55',
      'route': 'Home — service',
    });

    expect(prefill.title, 'Oil filter');
    expect(prefill.mileageKm, 15000);
    expect(prefill.currentMileageKm, 16000);
    expect(prefill.cost, 1200);
    expect(prefill.description, 'Filter replacement');
    expect(prefill.replacedParts, 'Oil filter, engine oil');
    expect(prefill.tripStartMileageKm, 16000);
    expect(prefill.distanceKm, 42);
    expect(prefill.durationMinutes, 55);
    expect(prefill.route, 'Home — service');
  });

  test('does not round fractional integer fields', () {
    final prefill = HistoryEventFormPrefill.fromQueryParameters(const {
      'mileageKm': '15000.5',
      'cost': '1000.25',
    });

    expect(prefill.mileageKm, isNull);
    expect(prefill.cost, isNull);
  });
}
