import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:go_router/go_router.dart';

List<int> analyticsMileageYearOptions({DateTime? now}) {
  final currentYear = (now ?? DateTime.now()).year;
  return [for (var year = currentYear; year >= currentYear - 4; year--) year];
}

Future<AnalyticsDateRange?> selectAnalyticsDateRange(
  BuildContext context, {
  AnalyticsDateRange? initialRange,
  DateTime? now,
}) async {
  final currentDate = now ?? DateTime.now();
  final materialLocalizations = MaterialLocalizations.of(context);
  final pickedRange = await showNativeDateRangePicker(
    context: context,
    firstDate: DateTime(currentDate.year - 10),
    lastDate: currentDate,
    initialDateRange: DateTimeRange(
      start:
          initialRange?.startDate ??
          currentDate.subtract(const Duration(days: 30)),
      end: initialRange?.endDate ?? currentDate,
    ),
    startTitle: materialLocalizations.dateRangeStartLabel,
    endTitle: materialLocalizations.dateRangeEndLabel,
  );

  if (pickedRange == null || !context.mounted) {
    return null;
  }

  return AnalyticsDateRange(
    startDate: pickedRange.start,
    endDate: pickedRange.end,
  );
}

void openAnalyticsHistoryAdd(
  BuildContext context, {
  required String vehicleId,
  String? type,
}) {
  final route = Uri(
    path: '/vehicle/$vehicleId/history/add',
    queryParameters: type == null ? null : {'type': type},
  ).toString();
  unawaited(context.push(route));
}
