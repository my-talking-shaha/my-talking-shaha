import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/providers/vehicle_mileage_provider.dart';
import 'package:frontend/features/analytics/di/analytics_providers.dart';
import 'package:frontend/features/dashboard/di/dashboard_providers.dart';
import 'package:frontend/features/garage/di/garage_providers.dart';
import 'package:frontend/features/history/di/history_providers.dart';
import 'package:frontend/features/parts/di/parts_providers.dart';

typedef InvalidateAfterHistoryMutation = void Function(String vehicleId);

final historyMutationInvalidationProvider =
    Provider<InvalidateAfterHistoryMutation>((ref) {
      return (vehicleId) {
        ref.invalidate(historyEventsProvider(vehicleId));
        ref.invalidate(garageControllerProvider);
        ref.invalidate(vehicleMileageProvider(vehicleId));
        ref.invalidate(vehicleDashboardProvider(vehicleId));
        ref.invalidate(vehiclePartsProvider(vehicleId));
        ref.invalidate(analyticsSummaryProvider);
      };
    });
