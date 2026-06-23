import 'package:dio/dio.dart';
import 'package:frontend/features/history/data/datasources/history_datasource.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';

final class HistoryApiDatasource implements HistoryDatasource {
  const HistoryApiDatasource(this._dio);

  final Dio _dio;

  @override
  Future<List<HistoryEvent>> getEvents(String vehicleId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/vehicles/$vehicleId/timeline',
    );
    final events = response.data?['events'];

    if (events is! List) return const [];

    return events
        .whereType<Map<String, dynamic>>()
        .map((json) => HistoryApiEventMapper.fromJson(json, vehicleId))
        .toList(growable: false);
  }

  @override
  Future<void> addEvent(HistoryEvent event) async {
    final endpoint = switch (event.type) {
      HistoryEventType.fuel => 'refuel',
      HistoryEventType.maintenance => 'maintenance',
      HistoryEventType.trip => 'trip',
    };

    await _dio.post<Map<String, dynamic>>(
      '/vehicles/${event.carId}/timeline/$endpoint',
      data: HistoryApiEventMapper.createPayload(event),
    );
  }
}

abstract final class HistoryApiEventMapper {
  static HistoryEvent fromJson(Map<String, dynamic> json, String vehicleId) {
    final backendType = _stringValue(json['type']);
    final type = _eventType(backendType);
    final title =
        _nullableStringValue(json['title']) ??
        _nullableStringValue(json['name']) ??
        _fallbackTitle(type);
    final mileageKm =
        _intValue(json['mileageKm']) ??
        _intValue(json['endMileageKm']) ??
        _intValue(json['startMileageKm']) ??
        0;

    return HistoryEvent(
      id: _stringValue(json['id']),
      carId: vehicleId,
      type: type,
      occurredAt: _dateTimeValue(json['eventDateTime']),
      title: title,
      currentMileageKm: mileageKm,
      details: switch (type) {
        HistoryEventType.fuel => FuelDetails(
          cost: _intValue(json['cost']) ?? 0,
          liters: _intValue(json['liters']) ?? 0,
          fuelType: _fuelLabel(json),
        ),
        HistoryEventType.maintenance => MaintenanceDetails(
          description: _nullableStringValue(json['description']) ?? '',
          cost: _intValue(json['cost']),
          photoUrls: _stringListValue(json['photoUrls']),
        ),
        HistoryEventType.trip => TripDetails(
          startKm: _intValue(json['startMileageKm']) ?? mileageKm,
          endKm: _intValue(json['endMileageKm']) ?? mileageKm,
          route: _nullableStringValue(json['route']),
          duration: Duration(minutes: _intValue(json['durationMinutes']) ?? 0),
        ),
      },
    );
  }

  static Map<String, dynamic> createPayload(HistoryEvent event) {
    final details = event.details;

    return switch (details) {
      FuelDetails() => {
        'eventDateTime': _dateTimePayload(event.occurredAt),
        'mileageKm': event.currentMileageKm,
        'liters': details.liters,
        'cost': details.cost,
        'fuelType': _backendFuelType(details.fuelType),
        'fuelName': details.fuelType,
      },
      MaintenanceDetails() => {
        'eventDateTime': _dateTimePayload(event.occurredAt),
        'mileageKm': event.currentMileageKm,
        'name': event.title,
        'description': _maintenanceDescription(details),
        if (details.cost != null) 'cost': details.cost,
        if (details.photoUrls != null && details.photoUrls!.isNotEmpty)
          'photoUrls': details.photoUrls,
      },
      TripDetails() => {
        'eventDateTime': _dateTimePayload(event.occurredAt),
        'startMileageKm': details.startKm,
        'endMileageKm': details.endKm,
        if (details.route != null) 'route': details.route,
        'durationMinutes': details.duration.inMinutes,
      },
    };
  }

  static HistoryEventType _eventType(String value) {
    return switch (value.toUpperCase()) {
      'REFUEL' => HistoryEventType.fuel,
      'TRIP' => HistoryEventType.trip,
      'MAINTENANCE' ||
      'PART_REPLACEMENT' ||
      'REPAIR' => HistoryEventType.maintenance,
      _ => HistoryEventType.maintenance,
    };
  }

  static String _fallbackTitle(HistoryEventType type) {
    return switch (type) {
      HistoryEventType.fuel => 'Refueling',
      HistoryEventType.maintenance => 'Maintenance',
      HistoryEventType.trip => 'Trip',
    };
  }

  static String _fuelLabel(Map<String, dynamic> json) {
    final fuelName = _nullableStringValue(json['fuelName']);
    final stationName = _nullableStringValue(json['stationName']);
    if (fuelName != null && stationName != null) {
      return '$fuelName • $stationName';
    }

    return fuelName ?? _stringValue(json['fuelType']);
  }

  static String _backendFuelType(String value) {
    final lowerValue = value.toLowerCase();
    if (lowerValue.contains('diesel')) return 'DIESEL';
    if (lowerValue.contains('electric')) return 'ELECTRIC';
    if (lowerValue.contains('hybrid')) return 'HYBRID';
    if (lowerValue.contains('gas') || lowerValue.contains('octane')) {
      return 'GASOLINE';
    }

    return 'OTHER';
  }

  static String _maintenanceDescription(MaintenanceDetails details) {
    final replacedParts = details.replacedParts;
    if (replacedParts == null || replacedParts.isEmpty) {
      return details.description;
    }

    return '${details.description}\nReplaced parts: ${replacedParts.join(', ')}';
  }

  static String _dateTimePayload(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  static DateTime _dateTimeValue(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static String _stringValue(Object? value) {
    return value?.toString() ?? '';
  }

  static String? _nullableStringValue(Object? value) {
    final stringValue = value?.toString();
    return stringValue == null || stringValue.isEmpty ? null : stringValue;
  }

  static int? _intValue(Object? value) {
    return switch (value) {
      int intValue => intValue,
      num numValue => numValue.toInt(),
      String stringValue => num.tryParse(stringValue)?.toInt(),
      _ => null,
    };
  }

  static List<String>? _stringListValue(Object? value) {
    if (value is! List) return null;

    final list = value.map((item) => item.toString()).toList(growable: false);
    return list.isEmpty ? null : list;
  }
}
