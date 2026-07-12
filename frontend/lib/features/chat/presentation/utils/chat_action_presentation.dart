import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/features/chat/domain/entities/chat_action.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

String? chatActionDestination(String vehicleId, ChatAction action) {
  final type = action.type.toUpperCase();
  if (type == 'OPEN_SCREEN') {
    final path = switch (action.screen?.toUpperCase()) {
      'ANALYTICS' => '/vehicle/$vehicleId/analytics',
      'HISTORY' || 'TIMELINE' => '/vehicle/$vehicleId/history',
      'DASHBOARD' || 'MAINTENANCE_FORECAST' => '/vehicle/$vehicleId/dashboard',
      _ => null,
    };
    if (path == null) return null;

    return Uri(
      path: path,
      queryParameters: const {'from': 'chat'},
    ).toString();
  }

  if (type == 'OPEN_FORM') {
    final form = action.form?.toUpperCase();
    final routeType = switch (form) {
      'TRIP' => 'trip',
      'MAINTENANCE' || 'PART_REPLACEMENT' => 'maintenance',
      _ => 'fuel',
    };
    final query = <String, String>{'type': routeType};
    final mileageKm = action.prefill['mileageKm']?.toString();
    if (mileageKm != null && mileageKm.isNotEmpty) {
      query['mileageKm'] = mileageKm;
    }

    return Uri(
      path: '/vehicle/$vehicleId/history/add',
      queryParameters: query,
    ).toString();
  }

  return null;
}

void openChatAction(
  BuildContext context, {
  required ChatAction action,
  required String destination,
}) {
  if (action.type.toUpperCase() == 'OPEN_SCREEN') {
    context.go(destination);
    return;
  }
  unawaited(context.push(destination));
}

String chatActionLabel(AppLocalizations l10n, ChatAction action) {
  if (action.type.toUpperCase() == 'OPEN_SCREEN') {
    return switch (action.screen?.toUpperCase()) {
      'ANALYTICS' => l10n.openAnalytics,
      'HISTORY' || 'TIMELINE' => l10n.maintenanceHistory,
      'MAINTENANCE_FORECAST' => l10n.openForecast,
      'DASHBOARD' => l10n.openDashboard,
      _ => l10n.open,
    };
  }

  return switch (action.form?.toUpperCase()) {
    'REFUEL' => l10n.addRefuel,
    'TRIP' => l10n.addTrip,
    'PART_REPLACEMENT' => l10n.addPartRecord,
    'MAINTENANCE' => l10n.addMaintenance,
    _ => l10n.openForm,
  };
}

IconData chatActionIcon(ChatAction action) {
  if (action.type.toUpperCase() == 'OPEN_SCREEN') {
    return switch (action.screen?.toUpperCase()) {
      'ANALYTICS' => Icons.bar_chart_rounded,
      'HISTORY' || 'TIMELINE' => Icons.history_rounded,
      'MAINTENANCE_FORECAST' => Icons.build_circle_outlined,
      'DASHBOARD' => Icons.directions_car_filled_rounded,
      _ => Icons.open_in_new_rounded,
    };
  }

  return switch (action.form?.toUpperCase()) {
    'REFUEL' => Icons.local_gas_station_rounded,
    'TRIP' => Icons.route_rounded,
    'PART_REPLACEMENT' => Icons.build_circle_outlined,
    'MAINTENANCE' => Icons.handyman_rounded,
    _ => Icons.open_in_new_rounded,
  };
}
