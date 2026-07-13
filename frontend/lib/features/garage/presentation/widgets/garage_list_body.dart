import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/presentation/widgets/garage_header.dart';
import 'package:frontend/features/garage/presentation/widgets/vehicle_garage_card.dart';

final class GarageListBody extends StatelessWidget {
  const GarageListBody({
    required this.vehicles,
    required this.onAddVehicle,
    required this.onOpenVehicle,
    required this.onEditVehicle,
    required this.onDeleteVehicle,
    super.key,
  });

  final List<Vehicle> vehicles;
  final VoidCallback onAddVehicle;
  final ValueChanged<String> onOpenVehicle;
  final ValueChanged<String> onEditVehicle;
  final ValueChanged<Vehicle> onDeleteVehicle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GarageHeader(onAddVehicle: onAddVehicle),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                itemCount: vehicles.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.xl),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];

                  return VehicleGarageCard(
                    vehicle: vehicle,
                    onOpen: () => onOpenVehicle(vehicle.id),
                    onEdit: () => onEditVehicle(vehicle.id),
                    onDelete: () => onDeleteVehicle(vehicle),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
