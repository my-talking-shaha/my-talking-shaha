import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';

abstract interface class LiveTripActivityDatasource {
  Future<void> ensureStarted(LiveTripSession session);

  Future<void> end();
}

final class MethodChannelLiveTripActivityDatasource
    implements LiveTripActivityDatasource {
  const MethodChannelLiveTripActivityDatasource({
    MethodChannel channel = const MethodChannel(_channelName),
  }) : _channel = channel;

  static const _channelName = 'my_talking_shaha/live_trip_activity';

  final MethodChannel _channel;

  @override
  Future<void> ensureStarted(LiveTripSession session) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;

    await _channel.invokeMethod<void>('ensureStarted', {
      'vehicleId': session.vehicleId,
      'vehicleName': session.vehicleName,
      'startMileageKm': session.startMileageKm,
      'startedAtMilliseconds': session.startedAt.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> end() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    await _channel.invokeMethod<void>('end');
  }
}
