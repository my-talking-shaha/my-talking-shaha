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

  @override
  Future<void> updateEvent(HistoryEvent event) async {
    await _dio.patch<Map<String, dynamic>>(
      '/vehicles/${event.carId}/timeline/${event.id}',
      data: HistoryApiEventMapper.createPayload(event),
    );
  }

  @override
  Future<void> deleteEvent(String vehicleId, String eventId) async {
    await _dio.delete<void>('/vehicles/$vehicleId/timeline/$eventId');
  }
}

abstract final class HistoryApiEventMapper {
  static HistoryEvent fromJson(Map<String, dynamic> json, String vehicleId) {
    final backendType = _stringValue(json['type']);
    final type = _eventType(backendType);
    final mileageKm =
        _intValue(json['mileageKm']) ??
        _intValue(json['endMileageKm']) ??
        _intValue(json['startMileageKm']) ??
        0;
    final maintenanceDescription = _maintenanceDetailsDescription(
      _nullableStringValue(json['description']) ?? '',
    );

    return HistoryEvent(
      id: _stringValue(json['id']),
      carId: vehicleId,
      type: type,
      occurredAt: _dateTimeValue(json['eventDateTime']),
      title: _title(json, type),
      currentMileageKm: mileageKm,
      details: switch (type) {
        HistoryEventType.fuel => FuelDetails(
          cost: _intValue(json['cost']) ?? 0,
          liters: _doubleValue(json['liters']) ?? 0,
          fuelType: _fuelLabel(json),
        ),
        HistoryEventType.maintenance => MaintenanceDetails(
          description: maintenanceDescription.description,
          cost: _intValue(json['cost']),
          replacedParts: maintenanceDescription.replacedParts,
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
        'title': event.title,
        'eventDateTime': _dateTimePayload(event.occurredAt),
        'mileageKm': event.currentMileageKm,
        'liters': details.liters,
        'cost': details.cost,
        'fuelType': _backendFuelType(details.fuelType),
        'fuelName': _fuelNamePayload(details.fuelType),
        'stationName': ?_stationNamePayload(details.fuelType),
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
        'title': event.title,
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

  static String _title(Map<String, dynamic> json, HistoryEventType type) {
    return switch (type) {
      HistoryEventType.fuel => _refuelTitle(json),
      HistoryEventType.trip => _tripTitle(json),
      HistoryEventType.maintenance =>
        _nullableStringValue(json['name']) ??
            _nullableStringValue(json['title']) ??
            _fallbackTitle(type),
    };
  }

  static String _refuelTitle(Map<String, dynamic> json) {
    final title = _nullableStringValue(json['title']);
    if (title != null && !_isGenericRefuelTitle(title)) {
      return title;
    }

    final fuelName = _nullableStringValue(json['fuelName']);
    return fuelName == null ? 'Refueling' : 'Refueling $fuelName';
  }

  static String _tripTitle(Map<String, dynamic> json) {
    final title = _nullableStringValue(json['title']);
    if (title != null && !_isGenericTripTitle(title)) {
      return title;
    }

    final route = _nullableStringValue(json['route']);
    if (route != null) {
      return route;
    }

    final distanceKm = _intValue(json['distanceKm']);
    return distanceKm == null ? 'Trip' : 'Trip $distanceKm km';
  }

  static bool _isGenericRefuelTitle(String title) {
    final normalizedTitle = title.trim().toLowerCase();
    return normalizedTitle == 'заправка' ||
        normalizedTitle == 'refueling' ||
        normalizedTitle == 'fueling' ||
        normalizedTitle == 'fuel';
  }

  static bool _isGenericTripTitle(String title) {
    final normalizedTitle = title.trim().toLowerCase();
    return normalizedTitle == 'trip' || normalizedTitle == 'поездка';
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
    final lowerValue = _fuelNamePayload(value).toLowerCase();
    if (lowerValue.contains('diesel') || lowerValue.contains('диз')) {
      return 'DIESEL';
    }
    if (lowerValue.contains('electric')) return 'ELECTRIC';
    if (lowerValue.contains('hybrid')) return 'HYBRID';
    if (lowerValue.contains('gas') ||
        lowerValue.contains('petrol') ||
        lowerValue.contains('benz') ||
        lowerValue.contains('бенз') ||
        lowerValue.contains('octane') ||
        RegExp(r'(ai|аи|a)[\s-]?(92|95|98|100)').hasMatch(lowerValue)) {
      return 'GASOLINE';
    }

    return 'OTHER';
  }

  static String _fuelNamePayload(String value) {
    return _splitFuelLabel(value).$1;
  }

  static String? _stationNamePayload(String value) {
    return _splitFuelLabel(value).$2;
  }

  static (String, String?) _splitFuelLabel(String value) {
    final parts = value.split('•');
    final fuelName = parts.first.trim();
    if (parts.length == 1) {
      return (fuelName, null);
    }

    final stationName = parts.skip(1).join('•').trim();
    return (fuelName, stationName.isEmpty ? null : stationName);
  }

  static String _maintenanceDescription(MaintenanceDetails details) {
    final replacedParts = details.replacedParts;
    if (replacedParts == null || replacedParts.isEmpty) {
      return details.description;
    }

    return '${details.description}\nReplaced parts: ${replacedParts.join(', ')}';
  }

  static ({String description, List<String>? replacedParts})
  _maintenanceDetailsDescription(String description) {
    final lines = description.split('\n');
    final cleanDescription = <String>[];
    final replacedParts = <String>[];

    for (final line in lines) {
      final match = RegExp(
        r'^\s*Replaced parts:\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (match == null) {
        cleanDescription.add(line);
        continue;
      }

      replacedParts.addAll(
        match
            .group(1)!
            .split(',')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty),
      );
    }

    return (
      description: cleanDescription.join('\n').trim(),
      replacedParts: replacedParts.isEmpty ? null : replacedParts,
    );
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

  static double? _doubleValue(Object? value) {
    return switch (value) {
      num numValue => numValue.toDouble(),
      String stringValue => num.tryParse(stringValue)?.toDouble(),
      _ => null,
    };
  }

  static List<String>? _stringListValue(Object? value) {
    if (value is! List) return null;

    final list = value.map((item) => item.toString()).toList(growable: false);
    return list.isEmpty ? null : list;
  }
}
