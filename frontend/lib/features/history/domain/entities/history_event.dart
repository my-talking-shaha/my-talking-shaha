import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';

class HistoryEvent {
  final String id;
  final String carId;
  final HistoryEventType type;
  final DateTime occurredAt;
  final String title;
  final int currentMileageKm;
  final EventDetails details;

  const HistoryEvent({
    required this.id,
    required this.carId,
    required this.type,
    required this.occurredAt,
    required this.title,
    required this.details,
    required this.currentMileageKm,
  });
}
