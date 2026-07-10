import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/presentation/colors.dart';
import 'package:frontend/features/parts/presentation/utils/maintenance_forecast_utils.dart';
import 'package:frontend/features/parts/presentation/utils/part_resource_utils.dart';
import 'package:frontend/features/parts/presentation/utils/parts_number_formatter.dart';
import 'package:frontend/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('forecast helpers preserve averaging and nearest-resource rules', () {
    final parts = [
      _part(
        percent: -10,
        remainingKm: -100,
        status: PartResourceStatus.critical,
      ),
      _part(percent: 51, remainingKm: 2400),
      _part(percent: 140, remainingKm: 800),
      _part(),
    ];

    expect(averagePartsPercent(parts), 50);
    expect(nearestPositiveRemainingKm(parts), 800);
    expect(criticalParts(parts), [parts.first]);
    expect(averagePartsPercent([_part()]), isNull);
  });

  test('forecast copy preserves critical, future, and no-data precedence', () {
    final critical = [_part(name: 'Battery')];

    expect(
      forecastHeadline(
        l10n,
        criticalParts: critical,
        nextPositiveRemainingKm: 800,
      ),
      'Service needed now',
    );
    expect(
      forecastCaption(
        l10n,
        criticalParts: critical,
        nextPositiveRemainingKm: 800,
      ),
      'Replace Battery now',
    );
    expect(
      forecastCaption(
        l10n,
        criticalParts: [
          critical.first,
          _part(name: 'Timing belt'),
        ],
        nextPositiveRemainingKm: null,
      ),
      'Replace 2 critical parts now',
    );
    expect(
      forecastHeadline(
        l10n,
        criticalParts: const [],
        nextPositiveRemainingKm: 2400,
      ),
      'In 2 400 km',
    );
    expect(
      forecastCaption(
        l10n,
        criticalParts: const [],
        nextPositiveRemainingKm: 800,
      ),
      'Approx. date: in 16 days',
    );
    expect(
      forecastHeadline(
        l10n,
        criticalParts: const [],
        nextPositiveRemainingKm: null,
      ),
      'Not enough data',
    );
    expect(
      forecastCaption(
        l10n,
        criticalParts: const [],
        nextPositiveRemainingKm: null,
      ),
      'Add lifetime data to forecast',
    );
  });

  test('row helpers preserve formatting, clamping, and status colors', () {
    expect(formatPartsInteger(1234567), '1 234 567');
    expect(formatPartsInteger(-2400), '-2 400');
    expect(
      partResourceText(l10n, _part(percent: 120, remainingKm: -20)),
      '100% · 0 km',
    );
    expect(partResourceText(l10n, _part(percent: 10)), 'Lifetime not set');
    expect(partProgressValue(_part(percent: -10)), 0);
    expect(partProgressValue(_part(percent: 120)), 1);
    expect(partProgressValue(_part()), isNull);
    expect(partStatusColor(PartResourceStatus.ok), PartsColors.ok);
    expect(partStatusColor(PartResourceStatus.warning), PartsColors.warning);
    expect(partStatusColor(PartResourceStatus.critical), PartsColors.critical);
    expect(partStatusColor(PartResourceStatus.unknown), PartsColors.unknown);
  });
}

VehiclePart _part({
  String name = 'Part',
  int? percent,
  int? remainingKm,
  PartResourceStatus status = PartResourceStatus.ok,
}) {
  return VehiclePart(
    id: name,
    vehicleId: 'vehicle_123',
    name: name,
    catalogKey: null,
    installedAt: DateTime.utc(2026, 6, 1),
    installedAtMileageKm: 100000,
    lifetimeKm: percent == null ? null : 10000,
    remainingKm: remainingKm,
    remainingPercent: percent,
    status: status,
  );
}
