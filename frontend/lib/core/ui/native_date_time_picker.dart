import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/native_ui_platform.dart';

Future<DateTime?> showNativeDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? title,
}) {
  if (!usesCupertinoNativeUi(context)) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  return _showCupertinoDatePicker(
    context: context,
    initialDate: _clampDate(initialDate, firstDate, lastDate),
    minimumDate: firstDate,
    maximumDate: lastDate,
    title: title,
  );
}

Future<TimeOfDay?> showNativeTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? title,
}) async {
  if (!usesCupertinoNativeUi(context)) {
    return showTimePicker(context: context, initialTime: initialTime);
  }

  final now = DateTime.now();
  final selected = await _showCupertinoDatePicker(
    context: context,
    initialDate: DateTime(
      now.year,
      now.month,
      now.day,
      initialTime.hour,
      initialTime.minute,
    ),
    mode: CupertinoDatePickerMode.time,
    use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    title: title,
  );
  return selected == null ? null : TimeOfDay.fromDateTime(selected);
}

Future<DateTimeRange?> showNativeDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  required DateTimeRange initialDateRange,
  String? startTitle,
  String? endTitle,
}) async {
  if (!usesCupertinoNativeUi(context)) {
    return showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
    );
  }

  final start = await _showCupertinoDatePicker(
    context: context,
    initialDate: _clampDate(initialDateRange.start, firstDate, lastDate),
    minimumDate: firstDate,
    maximumDate: lastDate,
    title: startTitle,
  );
  if (start == null || !context.mounted) return null;

  final initialEnd = _clampDate(initialDateRange.end, start, lastDate);
  final end = await _showCupertinoDatePicker(
    context: context,
    initialDate: initialEnd,
    minimumDate: start,
    maximumDate: lastDate,
    title: endTitle,
  );
  if (end == null) return null;

  return DateTimeRange(start: start, end: end);
}

Future<DateTime?> _showCupertinoDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
  DateTime? minimumDate,
  DateTime? maximumDate,
  bool use24hFormat = false,
  String? title,
}) {
  var selectedDate = initialDate;
  final theme = Theme.of(context);
  final localizations = CupertinoLocalizations.of(context);
  final materialLocalizations = MaterialLocalizations.of(context);

  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (sheetContext) => CupertinoTheme(
      data: CupertinoThemeData(
        brightness: theme.brightness,
        primaryColor: theme.colorScheme.primary,
        scaffoldBackgroundColor: theme.colorScheme.surface,
        textTheme: CupertinoTextThemeData(
          dateTimePickerTextStyle:
              theme.textTheme.bodyLarge ?? const TextStyle(),
        ),
      ),
      child: CupertinoPopupSurface(
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 320,
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(localizations.cancelButtonLabel),
                      ),
                      if (title != null)
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                        )
                      else
                        const Spacer(),
                      CupertinoButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(selectedDate),
                        child: Text(materialLocalizations.okButtonLabel),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: mode,
                    initialDateTime: initialDate,
                    minimumDate: minimumDate,
                    maximumDate: maximumDate,
                    use24hFormat: use24hFormat,
                    onDateTimeChanged: (value) => selectedDate = value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

DateTime _clampDate(DateTime value, DateTime minimum, DateTime maximum) {
  if (value.isBefore(minimum)) return minimum;
  if (value.isAfter(maximum)) return maximum;
  return value;
}
