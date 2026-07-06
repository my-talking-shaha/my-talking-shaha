import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/garage/data/datasources/garage_api_datasource.dart';
import 'package:frontend/features/garage/domain/entities/vehicle_draft.dart';

void main() {
  group('GarageApiDatasource', () {
    test('loads vehicle brands from backend catalog', () async {
      final adapter = _RecordingHttpClientAdapter(
        responseData: const ['BMW', ' Lada ', '', 'Toyota'],
      );
      final datasource = GarageApiDatasource(
        Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
          ..httpClientAdapter = adapter,
      );

      final brands = await datasource.getVehicleBrands();

      expect(adapter.requestedPath, '/api/v1/vehicles/brands');
      expect(brands, ['BMW', 'Lada', 'Toyota']);
    });
  });

  group('GarageApiVehicleMapper', () {
    test('maps backend vehicle response to garage domain vehicle', () {
      final vehicle = GarageApiVehicleMapper.fromJson(const {
        'id': '096c10bb-13d1-4599-9109-e9e79789ea88',
        'brand': 'Lada',
        'model': '2106',
        'productionYear': 2002,
        'color': 'green',
        'mileageKm': 10000,
        'fuelType': 'GASOLINE',
        'engineDescription': '1.6 L',
        'vin': 'XTA21060012345678',
        'photoUrl': 'https://example.com/car.jpg',
      });

      expect(vehicle.id, '096c10bb-13d1-4599-9109-e9e79789ea88');
      expect(vehicle.brand, 'Lada');
      expect(vehicle.model, '2106');
      expect(vehicle.year, 2002);
      expect(vehicle.color, 'green');
      expect(vehicle.currentMileageKm, 10000);
      expect(vehicle.engineType, 'gasoline');
      expect(vehicle.engineVolumeLiters, 1.6);
      expect(vehicle.enginePowerHp, isNull);
      expect(vehicle.vin, 'XTA21060012345678');
      expect(vehicle.photoUrl, 'https://example.com/car.jpg');
    });

    test('builds backend create payload from combustion draft', () {
      final payload = GarageApiVehicleMapper.createPayload(
        const VehicleDraft(
          brand: 'Lada',
          model: '2106',
          year: 2002,
          color: 'green',
          currentMileageKm: 10000,
          engineType: 'gasoline',
          engineVolumeLiters: 1.6,
          enginePowerHp: null,
          vin: 'XTA21060012345678',
        ),
      );

      expect(payload, {
        'brand': 'Lada',
        'model': '2106',
        'productionYear': 2002,
        'color': 'green',
        'mileageKm': 10000,
        'fuelType': 'GASOLINE',
        'engineDescription': '1.6 L',
        'vin': 'XTA21060012345678',
      });
    });

    test('maps electric engine description to power output', () {
      final vehicle = GarageApiVehicleMapper.fromJson(const {
        'id': 'vehicle_1',
        'brand': 'Tesla',
        'model': 'Model 3',
        'productionYear': 2024,
        'mileageKm': 1000,
        'fuelType': 'ELECTRIC',
        'engineDescription': '283 hp',
      });

      expect(vehicle.engineType, 'electric');
      expect(vehicle.engineVolumeLiters, isNull);
      expect(vehicle.enginePowerHp, 283);
    });
  });
}

final class _RecordingHttpClientAdapter implements HttpClientAdapter {
  _RecordingHttpClientAdapter({required this.responseData});

  final Object? responseData;
  String? requestedPath;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedPath = options.uri.path;
    return ResponseBody.fromString(
      jsonEncode(responseData),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
