import 'package:frontend/features/history/domain/entities/live_trip_session.dart';

abstract interface class LiveTripRepository {
  Future<LiveTripSession?> restore();

  Future<void> start(LiveTripSession session);

  Future<void> end();
}
