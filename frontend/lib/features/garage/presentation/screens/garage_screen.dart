import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/garage/di/garage_providers.dart';
import 'package:frontend/features/garage/presentation/utils/garage_dialog_utils.dart';
import 'package:frontend/features/garage/presentation/widgets/garage_empty_state.dart';
import 'package:frontend/features/garage/presentation/widgets/garage_error_state.dart';
import 'package:frontend/features/garage/presentation/widgets/garage_list_body.dart';
import 'package:go_router/go_router.dart';

final class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesState = ref.watch(garageControllerProvider);

    return Scaffold(
      body: vehiclesState.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return GarageEmptyState(
              onAddVehicle: () => context.go('/garage/add'),
            );
          }

          return GarageListBody(
            vehicles: vehicles,
            onAddVehicle: () => context.go('/garage/add'),
            onOpenVehicle: (vehicleId) {
              context.go('/vehicle/$vehicleId/chat');
            },
            onEditVehicle: (vehicleId) {
              context.go('/garage/edit/$vehicleId');
            },
            onDeleteVehicle: (vehicle) {
              unawaited(
                confirmAndDeleteGarageVehicle(
                  context: context,
                  vehicle: vehicle,
                  onDelete: ref
                      .read(garageControllerProvider.notifier)
                      .deleteVehicle,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => GarageErrorState(
          onRetry: () {
            unawaited(ref.read(garageControllerProvider.notifier).reload());
          },
        ),
      ),
    );
  }
}
