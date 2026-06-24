import 'package:dio/dio.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:frontend/features/garage/data/datasources/garage_api_datasource.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/parts/data/datasources/parts_api_datasource.dart';

final class DashboardApiDatasource {
  const DashboardApiDatasource(this._dio);

  final Dio _dio;

  Future<DashboardData> getDashboard(String vehicleId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/vehicles/$vehicleId/dashboard',
    );
    final data = response.data ?? const {};
    final forecast = data['maintenanceForecast'];
    final parts = forecast is Map<String, dynamic> ? forecast['parts'] : null;
    final recentEvents = data['recentEvents'];

    return DashboardData(
      vehicle: GarageApiVehicleMapper.fromJson(_mapValue(data['vehicle'])),
      maintenanceParts: _listValue(parts)
          .map(
            (json) => PartsApiPartMapper.fromJson(json, vehicleId: vehicleId),
          )
          .toList(growable: false),
      recentEvents: _listValue(
        recentEvents,
      ).map(DashboardApiEventMapper.fromJson).toList(growable: false),
    );
  }

  static Map<String, dynamic> _mapValue(Object? value) {
    return value is Map<String, dynamic> ? value : const {};
  }

  static Iterable<Map<String, dynamic>> _listValue(Object? value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>();
  }
}

abstract final class DashboardApiEventMapper {
  static DashboardRecentEvent fromJson(Map<String, dynamic> json) {
    return DashboardRecentEvent(
      id: _stringValue(json['id']),
      type: _eventType(json['type']),
      title:
          _nullableStringValue(json['title']) ?? _fallbackTitle(json['type']),
      subtitle: _nullableStringValue(json['subtitle']) ?? '',
      occurredAt:
          DateTime.tryParse(_stringValue(json['eventDateTime'])) ??
          DateTime.now(),
    );
  }

  static HistoryEventType _eventType(Object? value) {
    return switch (_stringValue(value).toUpperCase()) {
      'REFUEL' => HistoryEventType.fuel,
      'TRIP' => HistoryEventType.trip,
      'MAINTENANCE' ||
      'PART_REPLACEMENT' ||
      'REPAIR' => HistoryEventType.maintenance,
      _ => HistoryEventType.maintenance,
    };
  }

  static String _fallbackTitle(Object? value) {
    return switch (_eventType(value)) {
      HistoryEventType.fuel => 'Refueling',
      HistoryEventType.maintenance => 'Maintenance',
      HistoryEventType.trip => 'Trip',
    };
  }

  static String _stringValue(Object? value) {
    return value?.toString() ?? '';
  }

  static String? _nullableStringValue(Object? value) {
    final stringValue = value?.toString();
    return stringValue == null || stringValue.isEmpty ? null : stringValue;
  }
}
