import 'package:dio/dio.dart';
import 'package:frontend/features/parts/data/datasources/parts_datasource.dart';
import 'package:frontend/features/parts/domain/entities/vehicle_part.dart';

final class PartsApiDatasource implements PartsDatasource {
  const PartsApiDatasource(this._dio);

  final Dio _dio;

  @override
  Future<List<VehiclePart>> getParts({required String vehicleId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/vehicles/$vehicleId/parts',
    );
    final data = response.data ?? const {};
    final parts = data['parts'];

    if (parts is! List) {
      return const [];
    }

    return parts
        .whereType<Map<String, dynamic>>()
        .map((json) => PartsApiPartMapper.fromJson(json, vehicleId: vehicleId))
        .toList(growable: false);
  }

  @override
  Future<int?> getCurrentVehicleMileageKm({required String vehicleId}) async {
    return null;
  }
}

abstract final class PartsApiPartMapper {
  static VehiclePart fromJson(
    Map<String, dynamic> json, {
    required String vehicleId,
  }) {
    return VehiclePart(
      id: _stringValue(json['id']),
      vehicleId: vehicleId,
      name: _stringValue(json['name']),
      catalogKey: _catalogKey(json['category']),
      installedAt: _dateValue(json['installedAt']),
      installedAtMileageKm: _intValue(json['installedMileageKm']),
      lifetimeKm: _nullableIntValue(json['expectedLifetimeKm']),
      remainingKm: _nullableIntValue(json['remainingKm']),
      remainingPercent: _nullableIntValue(json['remainingPercent']),
      status: _statusValue(json['status']),
    );
  }

  static String _stringValue(Object? value) {
    return value?.toString() ?? '';
  }

  static String? _catalogKey(Object? value) {
    final stringValue = value?.toString();
    return stringValue == null || stringValue.isEmpty
        ? null
        : stringValue.toLowerCase();
  }

  static DateTime _dateValue(Object? value) {
    final stringValue = value?.toString();
    if (stringValue == null || stringValue.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    final dateOnlyMatch = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})$',
    ).firstMatch(stringValue);
    if (dateOnlyMatch != null) {
      return DateTime.utc(
        int.parse(dateOnlyMatch.group(1)!),
        int.parse(dateOnlyMatch.group(2)!),
        int.parse(dateOnlyMatch.group(3)!),
      );
    }

    return DateTime.tryParse(stringValue)?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static int _intValue(Object? value) {
    return _nullableIntValue(value) ?? 0;
  }

  static int? _nullableIntValue(Object? value) {
    return switch (value) {
      int intValue => intValue,
      num numValue => numValue.toInt(),
      String stringValue => int.tryParse(stringValue),
      _ => null,
    };
  }

  static PartResourceStatus _statusValue(Object? value) {
    return switch (value?.toString().toUpperCase()) {
      'OK' => PartResourceStatus.ok,
      'ATTENTION' => PartResourceStatus.warning,
      'CRITICAL' => PartResourceStatus.critical,
      'UNKNOWN' => PartResourceStatus.unknown,
      _ => PartResourceStatus.unknown,
    };
  }
}
