import 'package:flutter/material.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';
import 'package:frontend/features/parts/presentation/colors.dart';
import 'package:frontend/features/parts/presentation/utils/parts_number_formatter.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

double? partProgressValue(VehiclePart part) {
  final remainingPercent = part.remainingPercent;

  return remainingPercent == null
      ? null
      : (remainingPercent / 100).clamp(0.0, 1.0).toDouble();
}

String partResourceText(AppLocalizations l10n, VehiclePart part) {
  final remainingKm = part.remainingKm;
  final remainingPercent = part.remainingPercent;

  if (remainingKm == null || remainingPercent == null) {
    return l10n.lifetimeNotSet;
  }

  final displayPercent = remainingPercent.clamp(0, 100);
  final displayRemainingKm = remainingKm < 0 ? 0 : remainingKm;

  return '$displayPercent% · ${formatPartsInteger(displayRemainingKm)} km';
}

Color partStatusColor(PartResourceStatus status) {
  return switch (status) {
    PartResourceStatus.ok => PartsColors.ok,
    PartResourceStatus.warning => PartsColors.warning,
    PartResourceStatus.critical => PartsColors.critical,
    PartResourceStatus.unknown => PartsColors.unknown,
  };
}
