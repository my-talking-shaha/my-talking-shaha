import 'package:dio/dio.dart';
import 'package:frontend/features/garage/data/datasources/garage_datasource.dart';
import 'package:frontend/features/garage/domain/entities/vehicle.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';

final class GarageApiDatasource implements GarageDatasource {
  const GarageApiDatasource(this._dio);

  final Dio _dio;

  @override
  Future<List<Vehicle>> getVehicles() async {
    final response = await _dio.get<List<dynamic>>('/vehicles');
    final data = response.data ?? const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(GarageApiVehicleMapper.fromJson)
        .toList(growable: false);
  }

  @override
  Future<Vehicle> addVehicle(VehicleDraft draft) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/vehicles',
      data: GarageApiVehicleMapper.createPayload(draft.trimmed()),
    );

    return GarageApiVehicleMapper.fromJson(response.data ?? const {});
  }

  @override
  Future<Vehicle> updateVehicle(String vehicleId, VehicleDraft draft) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/vehicles/$vehicleId',
      data: GarageApiVehicleMapper.updatePayload(draft.trimmed()),
    );

    return GarageApiVehicleMapper.fromJson(response.data ?? const {});
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    await _dio.delete<void>('/vehicles/$vehicleId');
  }
}

abstract final class GarageApiVehicleMapper {
  static Vehicle fromJson(Map<String, dynamic> json) {
    final fuelType = _stringValue(json['fuelType']).toLowerCase();
    final engineDescription = _stringValue(json['engineDescription']);

    return Vehicle(
      id: _stringValue(json['id']),
      brand: _stringValue(json['brand']),
      model: _stringValue(json['model']),
      year: _intValue(json['productionYear']),
      color: _nullableStringValue(json['color']),
      currentMileageKm: _intValue(json['mileageKm']),
      engineType: fuelType,
      engineVolumeLiters: fuelType == 'electric'
          ? null
          : _engineVolumeFromDescription(engineDescription),
      enginePowerHp: fuelType == 'electric'
          ? _enginePowerFromDescription(engineDescription)
          : null,
      vin: _nullableStringValue(json['vin']),
      photoUrl: _nullableStringValue(json['photoUrl']),
      status: 'unknown',
      activeWarningsCount: 0,
    );
  }

  static Map<String, dynamic> createPayload(VehicleDraft draft) {
    return {
      'brand': draft.brand,
      'model': draft.model,
      'productionYear': draft.year,
      'color': draft.color,
      'mileageKm': draft.currentMileageKm,
      'fuelType': draft.engineType.toUpperCase(),
      'engineDescription': _engineDescription(draft),
      'vin': draft.vin,
    };
  }

  static Map<String, dynamic> updatePayload(VehicleDraft draft) {
    return createPayload(draft);
  }

  static String? _engineDescription(VehicleDraft draft) {
    if (draft.engineType.toLowerCase() == 'electric') {
      final power = draft.enginePowerHp;
      return power == null ? null : '$power hp';
    }

    final volume = draft.engineVolumeLiters;
    return volume == null ? null : '${_formatVolume(volume)} L';
  }

  static String _formatVolume(double volume) {
    return volume == volume.roundToDouble()
        ? volume.toStringAsFixed(0)
        : volume.toString();
  }

  static double? _engineVolumeFromDescription(String description) {
    final match = RegExp(
      r'(\d+(?:[,.]\d+)?)',
    ).firstMatch(description.replaceAll(',', '.'));
    final value = match?.group(1);

    return value == null ? null : double.tryParse(value);
  }

  static int? _enginePowerFromDescription(String description) {
    final match = RegExp(r'(\d+)').firstMatch(description);
    final value = match?.group(1);

    return value == null ? null : int.tryParse(value);
  }

  static String _stringValue(Object? value) {
    return value?.toString() ?? '';
  }

  static String? _nullableStringValue(Object? value) {
    final stringValue = value?.toString();
    return stringValue == null || stringValue.isEmpty ? null : stringValue;
  }

  static int _intValue(Object? value) {
    return switch (value) {
      int intValue => intValue,
      num numValue => numValue.toInt(),
      String stringValue => int.tryParse(stringValue) ?? 0,
      _ => 0,
    };
  }
}
