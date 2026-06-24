import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/parts/data/datasources/parts_api_datasource.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';

void main() {
  group('PartsApiPartMapper', () {
    test('maps backend part response to parts domain model', () {
      final part = PartsApiPartMapper.fromJson(const {
        'id': '023c10cc-13d1-4567-9109-e9e79789ea21',
        'name': 'Brake pads',
        'category': 'BRAKE_PADS',
        'installedAt': '2026-06-12',
        'installedMileageKm': 10000,
        'expectedLifetimeKm': 25000,
        'remainingKm': 500,
        'remainingPercent': 8,
        'status': 'ATTENTION',
        'description': 'Front axle',
        'cost': 2500,
        'photoUrls': <String>[],
      }, vehicleId: '096c10bb-13d1-4599-9109-e9e79789ea88');

      expect(part.id, '023c10cc-13d1-4567-9109-e9e79789ea21');
      expect(part.vehicleId, '096c10bb-13d1-4599-9109-e9e79789ea88');
      expect(part.name, 'Brake pads');
      expect(part.catalogKey, 'brake_pads');
      expect(part.installedAt, DateTime.utc(2026, 6, 12));
      expect(part.installedAtMileageKm, 10000);
      expect(part.lifetimeKm, 25000);
      expect(part.remainingKm, 500);
      expect(part.remainingPercent, 8);
      expect(part.status, PartResourceStatus.warning);
    });

    test('keeps unknown resource fields nullable', () {
      final part = PartsApiPartMapper.fromJson(const {
        'id': 'part_unknown',
        'name': 'Cabin filter',
        'category': 'OTHER',
        'installedAt': '2026-06-01',
        'installedMileageKm': 103500,
        'expectedLifetimeKm': null,
        'remainingKm': null,
        'remainingPercent': null,
        'status': 'UNKNOWN',
      }, vehicleId: 'vehicle_123');

      expect(part.catalogKey, 'other');
      expect(part.lifetimeKm, isNull);
      expect(part.remainingKm, isNull);
      expect(part.remainingPercent, isNull);
      expect(part.status, PartResourceStatus.unknown);
    });
  });
}
