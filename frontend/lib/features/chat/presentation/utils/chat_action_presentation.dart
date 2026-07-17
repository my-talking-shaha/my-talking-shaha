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
      'HISTORY_EVENT_EDIT' => _historyEventEditPath(vehicleId, action),
      _ => null,
    };
    if (path == null) return null;

    return Uri(path: path, queryParameters: const {'from': 'chat'}).toString();
  }

  if (type == 'OPEN_FORM') {
    final form = action.form?.toUpperCase();
    final routeType = switch (form) {
      'REFUEL' || 'RECHARGE' => 'fuel',
      'TRIP' => 'trip',
      'PART_REPLACEMENT' => 'part',
      'MAINTENANCE' => 'maintenance',
      _ => null,
    };
    if (routeType == null) return null;

    final query = <String, String>{'type': routeType, 'from': 'chat'};
    for (final key in _supportedFormPrefillKeys) {
      final value = _prefillQueryValue(action.prefill[key]);
      if (value != null) query[key] = value;
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
  required String destination,
  Object? extra,
}) {
  context.go(destination, extra: extra);
}

String chatActionLabel(AppLocalizations l10n, ChatAction action) {
  if (action.type.toUpperCase() == 'OPEN_SCREEN') {
    return switch (action.screen?.toUpperCase()) {
      'ANALYTICS' => l10n.openAnalytics,
      'HISTORY' || 'TIMELINE' => l10n.maintenanceHistory,
      'MAINTENANCE_FORECAST' => l10n.openForecast,
      'DASHBOARD' => l10n.openDashboard,
      'HISTORY_EVENT_EDIT' => _historyEventEditLabel(l10n, action),
      _ => l10n.open,
    };
  }

  return l10n.createEvent;
}

IconData chatActionIcon(ChatAction action) {
  if (action.type.toUpperCase() == 'OPEN_SCREEN') {
    return switch (action.screen?.toUpperCase()) {
      'ANALYTICS' => Icons.bar_chart_rounded,
      'HISTORY' || 'TIMELINE' => Icons.history_rounded,
      'MAINTENANCE_FORECAST' => Icons.build_circle_outlined,
      'DASHBOARD' => Icons.directions_car_filled_rounded,
      'HISTORY_EVENT_EDIT' => Icons.edit_rounded,
      _ => Icons.open_in_new_rounded,
    };
  }

  return switch (action.form?.toUpperCase()) {
    'REFUEL' => Icons.local_gas_station_rounded,
    'RECHARGE' => Icons.ev_station_rounded,
    'TRIP' => Icons.route_rounded,
    'PART_REPLACEMENT' => Icons.build_circle_outlined,
    'MAINTENANCE' => Icons.handyman_rounded,
    _ => Icons.open_in_new_rounded,
  };
}

const _supportedFormPrefillKeys = <String>{
  'eventDateTime',
  'title',
  'name',
  'partName',
  'part',
  'serviceType',
  'mileageKm',
  'currentMileageKm',
  'liters',
  'energyKwh',
  'kwh',
  'cost',
  'fuelType',
  'fuelName',
  'stationName',
  'chargerType',
  'description',
  'repairText',
  'replacedParts',
  'startMileageKm',
  'endMileageKm',
  'distanceKm',
  'route',
  'durationMinutes',
};

String? _historyEventEditPath(String vehicleId, ChatAction action) {
  final eventId = action.prefill['eventId']?.toString().trim();
  if (eventId == null || eventId.isEmpty) return null;
  return Uri(path: '/vehicle/$vehicleId/history/$eventId/edit').toString();
}

String _historyEventEditLabel(AppLocalizations l10n, ChatAction action) {
  return switch (action.prefill['eventType']?.toString().toUpperCase()) {
    'REFUEL' => l10n.editRefueling,
    'RECHARGE' => l10n.editRecharge,
    'TRIP' => l10n.editTrip,
    'PART_REPLACEMENT' => l10n.editPartRecord,
    'MAINTENANCE' || 'REPAIR' => l10n.editMaintenance,
    _ => l10n.editEvent,
  };
}

String? _prefillQueryValue(Object? value) {
  if (value == null) return null;
  if (value is Iterable) {
    final items = value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return items.isEmpty ? null : items.join(', ');
  }

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
