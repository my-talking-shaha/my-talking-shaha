import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/history/domain/entities/live_trip_session.dart';

final class CreateLiveTripEvent {
  const CreateLiveTripEvent();

  HistoryEvent call({
    required LiveTripSession session,
    required int endMileageKm,
    required DateTime endedAt,
    required String id,
    required String title,
    String? route,
  }) {
    if (endMileageKm < session.startMileageKm) {
      throw const LiveTripMileageException();
    }

    final elapsed = session.elapsedAt(endedAt);
    final roundedMinutes = elapsed.inSeconds <= 0
        ? 1
        : (elapsed.inSeconds + 59) ~/ 60;
    final normalizedRoute = route?.trim();

    return HistoryEvent(
      id: id,
      carId: session.vehicleId,
      type: HistoryEventType.trip,
      occurredAt: session.startedAt,
      title: title,
      currentMileageKm: endMileageKm,
      details: TripDetails(
        startKm: session.startMileageKm,
        endKm: endMileageKm,
        route: normalizedRoute == null || normalizedRoute.isEmpty
            ? null
            : normalizedRoute,
        duration: Duration(minutes: roundedMinutes),
      ),
    );
  }
}

final class LiveTripMileageException implements Exception {
  const LiveTripMileageException();
}
