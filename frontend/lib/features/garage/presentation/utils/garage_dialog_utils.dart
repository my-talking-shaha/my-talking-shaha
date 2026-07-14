import 'package:flutter/material.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

Future<void> confirmAndDeleteGarageVehicle({
  required BuildContext context,
  required Vehicle vehicle,
  required Future<void> Function(String vehicleId) onDelete,
}) async {
  final l10n = AppLocalizations.of(context);
  final vehicleName = '${vehicle.brand} ${vehicle.model}';
  final confirmed = await showNativeConfirmDialog(
    context: context,
    title: l10n.deleteVehicleQuestion,
    message: l10n.deleteVehicleConfirmation(vehicleName),
    cancelLabel: l10n.cancel,
    confirmLabel: l10n.delete,
    isDestructive: true,
  );

  if (confirmed) {
    await onDelete(vehicle.id);
  }
}
