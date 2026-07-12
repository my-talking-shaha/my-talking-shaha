import 'package:flutter/material.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';

abstract final class HistoryTimelineUtils {
  static bool isElectricEngine(String? engineType) {
    return engineType?.toLowerCase() == 'electric';
  }

  static String searchableText(HistoryEvent event) {
    final details = switch (event.details) {
      FuelDetails(:final fuelType, :final liters) => '$fuelType $liters',
      MaintenanceDetails(:final description, :final replacedParts) => [
          description,
          ...?replacedParts,
        ].join(' '),
      TripDetails(:final route) => route ?? '',
    };

    return '${event.title} $details'.toLowerCase();
  }

  static List<HistoryMonthGroup> groupByMonth(List<HistoryEvent> events) {
    final sortedEvents = [...events]
      ..sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
    final groups = <HistoryMonthGroup>[];

    for (final event in sortedEvents) {
      final month = DateTime(event.occurredAt.year, event.occurredAt.month);
      if (groups.isEmpty || groups.last.month != month) {
        groups.add(HistoryMonthGroup(month: month, events: [event]));
      } else {
        groups.last.events.add(event);
      }
    }

    return groups;
  }

  static String monthTitle(BuildContext context, DateTime month) {
    return MaterialLocalizations.of(
      context,
    ).formatMonthYear(month).toUpperCase();
  }
}

final class HistoryMonthGroup {
  HistoryMonthGroup({required this.month, required this.events});

  final DateTime month;
  final List<HistoryEvent> events;
}
