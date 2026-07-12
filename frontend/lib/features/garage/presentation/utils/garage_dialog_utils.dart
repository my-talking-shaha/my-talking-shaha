import 'package:flutter/material.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

Future<void> confirmAndDeleteGarageVehicle({
  required BuildContext context,
  required Vehicle vehicle,
  required Future<void> Function(String vehicleId) onDelete,
}) async {
  final l10n = AppLocalizations.of(context);
  final vehicleName = '${vehicle.brand} ${vehicle.model}';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.deleteVehicleQuestion),
        content: Text(l10n.deleteVehicleConfirmation(vehicleName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    await onDelete(vehicle.id);
  }
}
