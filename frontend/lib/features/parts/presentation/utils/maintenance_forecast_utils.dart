import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/presentation/utils/parts_number_formatter.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

const double _averageDailyMileageKm = 53;

int? averagePartsPercent(List<VehiclePart> parts) {
  final knownParts = parts
      .where((part) => part.remainingPercent != null)
      .toList(growable: false);
  if (knownParts.isEmpty) {
    return null;
  }

  final total = knownParts.fold<int>(
    0,
    (sum, part) => sum + part.remainingPercent!.clamp(0, 100).toInt(),
  );

  return (total / knownParts.length).round().clamp(0, 100);
}

List<VehiclePart> criticalParts(List<VehiclePart> parts) {
  return parts
      .where((part) => part.status == PartResourceStatus.critical)
      .toList(growable: false);
}

int? nearestPositiveRemainingKm(List<VehiclePart> parts) {
  return parts
      .map((part) => part.remainingKm)
      .whereType<int>()
      .where((remainingKm) => remainingKm > 0)
      .fold<int?>(null, (min, remainingKm) {
        if (min == null || remainingKm < min) {
          return remainingKm;
        }

        return min;
      });
}

String forecastHeadline(
  AppLocalizations l10n, {
  required List<VehiclePart> criticalParts,
  required int? nextPositiveRemainingKm,
}) {
  if (criticalParts.isNotEmpty) {
    return l10n.serviceNeededNow;
  }
  if (nextPositiveRemainingKm != null) {
    return l10n.inKm(formatPartsInteger(nextPositiveRemainingKm));
  }

  return l10n.notEnoughData;
}

String forecastCaption(
  AppLocalizations l10n, {
  required List<VehiclePart> criticalParts,
  required int? nextPositiveRemainingKm,
}) {
  if (criticalParts.length == 1) {
    return l10n.replacePartNow(criticalParts.first.name);
  }
  if (criticalParts.length > 1) {
    return l10n.replaceCriticalPartsNow(criticalParts.length);
  }
  if (nextPositiveRemainingKm != null) {
    final days = (nextPositiveRemainingKm / _averageDailyMileageKm).ceil();
    final displayDays = days < 1 ? 1 : days;

    return l10n.approxDateInDays(displayDays);
  }

  return l10n.addLifetimeData;
}
