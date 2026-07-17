import 'dart:convert';

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
        .map((json) => HistoryApiEventMapper.tryFromJson(json, vehicleId))
        .whereType<HistoryEvent>()
        .toList(growable: false);
  }

  @override
  Future<String> addEvent(HistoryEvent event) async {
    final payload = HistoryApiEventMapper.createPayload(event);
    final response = await _dio.post<Map<String, dynamic>>(
      '/vehicles/${event.carId}/timeline/'
      '${HistoryApiEventMapper.createEndpoint(event)}',
      data: event.type == HistoryEventType.maintenance
          ? await HistoryApiEventMapper.createMaintenanceFormData(
              event,
              payload,
            )
          : payload,
    );
    final eventId = response.data?['id']?.toString().trim() ?? '';
    if (eventId.isEmpty) {
      throw const FormatException('Created timeline event has no id');
    }
    return eventId;
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
  static HistoryEvent? tryFromJson(
    Map<String, dynamic> json,
    String vehicleId,
  ) {
    try {
      return fromJson(json, vehicleId);
    } catch (_) {
      return null;
    }
  }

  static String createEndpoint(HistoryEvent event) {
    return switch (event.type) {
      HistoryEventType.fuel =>
        _isRechargeDetails(event.details) ? 'recharge' : 'refuel',
      HistoryEventType.maintenance => 'maintenance',
      HistoryEventType.part => 'part',
      HistoryEventType.trip => 'trip',
    };
  }

  static HistoryEvent fromJson(Map<String, dynamic> json, String vehicleId) {
    final backendType = _stringValue(json['type']);
    final isRecharge = _isRechargeBackendType(backendType);
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
          cost: _doubleValue(json['cost']) ?? 0,
          liters: isRecharge
              ? _doubleValue(json['kwh']) ?? _doubleValue(json['liters']) ?? 0
              : _doubleValue(json['liters']) ?? 0,
          fuelType: _fuelLabel(json),
          isRecharge: isRecharge,
        ),
        HistoryEventType.maintenance => MaintenanceDetails(
          description: maintenanceDescription.description,
          cost: _doubleValue(json['cost']),
          replacedParts: maintenanceDescription.replacedParts,
          photoUrls: _stringListValue(json['photoUrls']),
        ),
        HistoryEventType.part => MaintenanceDetails(
          description: maintenanceDescription.description,
          cost: _doubleValue(json['cost']),
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
        if (_isRechargeDetails(details))
          'kwh': details.liters
        else
          'liters': details.liters,
        'cost': details.cost,
        'fuelType': _backendFuelType(details.fuelType),
        'fuelName': _fuelNamePayload(details.fuelType),
        'stationName': ?_stationNamePayload(details.fuelType),
      },
      MaintenanceDetails() => _maintenancePayload(event, details),
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

  static Future<FormData> createMaintenanceFormData(
    HistoryEvent event,
    Map<String, dynamic> payload,
  ) async {
    final details = event.details;
    final localPhotoPaths = details is MaintenanceDetails
        ? (details.photoUrls ?? const <String>[])
              .where((path) => !_isRemoteUrl(path))
              .where((path) => path.trim().isNotEmpty)
        : const Iterable<String>.empty();
    final photos = <MultipartFile>[];

    for (final path in localPhotoPaths) {
      photos.add(await MultipartFile.fromFile(path, filename: _fileName(path)));
    }

    return FormData.fromMap({
      'event': MultipartFile.fromString(
        jsonEncode(payload),
        filename: 'event.json',
        contentType: DioMediaType('application', 'json'),
      ),
      if (photos.isNotEmpty) 'photos': photos,
    });
  }

  static HistoryEventType _eventType(String value) {
    return switch (value.toUpperCase()) {
      'REFUEL' || 'RECHARGE' => HistoryEventType.fuel,
      'TRIP' => HistoryEventType.trip,
      'PART_REPLACEMENT' => HistoryEventType.part,
      'MAINTENANCE' || 'REPAIR' => HistoryEventType.maintenance,
      _ => HistoryEventType.maintenance,
    };
  }

  static String _fallbackTitle(HistoryEventType type) {
    return switch (type) {
      HistoryEventType.fuel => 'Refueling',
      HistoryEventType.maintenance => 'Maintenance',
      HistoryEventType.part => 'Part replacement',
      HistoryEventType.trip => 'Trip',
    };
  }

  static String _title(Map<String, dynamic> json, HistoryEventType type) {
    return switch (type) {
      HistoryEventType.fuel => _fuelTitle(json),
      HistoryEventType.trip => _tripTitle(json),
      HistoryEventType.part || HistoryEventType.maintenance =>
        _nullableStringValue(json['name']) ??
            _nullableStringValue(json['title']) ??
            _fallbackTitle(type),
    };
  }

  static String _fuelTitle(Map<String, dynamic> json) {
    final isRecharge = _isRechargeBackendType(_stringValue(json['type']));
    final title = _nullableStringValue(json['title']);
    if (title != null && !_isGenericFuelTitle(title)) {
      return title;
    }

    final fuelName = _nullableStringValue(json['fuelName']);
    final defaultTitle = isRecharge ? 'Recharge' : 'Refueling';
    return fuelName == null ? defaultTitle : '$defaultTitle $fuelName';
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

  static bool _isGenericFuelTitle(String title) {
    final normalizedTitle = title.trim().toLowerCase();
    return normalizedTitle == 'заправка' ||
        normalizedTitle == 'зарядка' ||
        normalizedTitle == 'refueling' ||
        normalizedTitle == 'fueling' ||
        normalizedTitle == 'fuel' ||
        normalizedTitle == 'recharge' ||
        normalizedTitle == 'charging' ||
        normalizedTitle == 'charge';
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
    if (lowerValue.contains('electric') ||
        lowerValue.contains('charging') ||
        lowerValue.contains('charger') ||
        lowerValue.contains('supercharger')) {
      return 'ELECTRIC';
    }
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

  static bool _isRechargeBackendType(String value) {
    return value.toUpperCase() == 'RECHARGE';
  }

  static bool _isRechargeDetails(EventDetails details) {
    return details is FuelDetails &&
        (details.isRecharge ||
            _backendFuelType(details.fuelType) == 'ELECTRIC');
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

  static Map<String, dynamic> _maintenancePayload(
    HistoryEvent event,
    MaintenanceDetails details,
  ) {
    return {
      'eventDateTime': _dateTimePayload(event.occurredAt),
      'mileageKm': event.currentMileageKm,
      if (details.currentMileageKm != null)
        'currentMileageKm': details.currentMileageKm,
      'name': event.title,
      'description': event.type == HistoryEventType.part
          ? details.description
          : _maintenanceDescription(details),
      if (details.cost != null) 'cost': details.cost,
      if (event.type == HistoryEventType.maintenance &&
          details.replacedParts != null &&
          details.replacedParts!.isNotEmpty)
        'replacedParts': details.replacedParts,
    };
  }

  static bool _isRemoteUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  static String _fileName(String path) {
    final segments = path.split(RegExp(r'[/\\]'));
    final fileName = segments.isEmpty ? '' : segments.last.trim();
    return fileName.isEmpty ? 'photo.jpg' : fileName;
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
