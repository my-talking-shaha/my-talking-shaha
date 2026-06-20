import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/domain/event_detais.dart';
import 'package:frontend/features/history/domain/history_event.dart';
import 'package:frontend/features/history/domain/history_event_type.dart';

class EventCard extends StatelessWidget {
  final HistoryEvent event;

  const EventCard({required this.event, super.key});

  @override
  Widget build(BuildContext context) {
    final details = event.details;
    final presentation = _EventPresentation.from(event);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventIcon(presentation: presentation),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (presentation.metric case final metric?) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        metric,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.primaryLight),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ..._detailWidgets(context, details),
                const SizedBox(height: AppSpacing.xs),
                _EventTimestamp(occurredAt: event.occurredAt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _detailWidgets(BuildContext context, EventDetails details) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return switch (details) {
      FuelDetails() => [
        Text('${details.liters} L • ${details.fuelType}', style: bodyStyle),
      ],
      MaintenanceDetails() => [
        if (details.description.trim().isNotEmpty)
          Text(details.description, style: bodyStyle),
        if (_nonEmptyParts(details).isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Replaced: ${_nonEmptyParts(details).join(', ')}',
            style: bodyStyle,
          ),
        ],
        if (_firstPhotoUrl(details) case final photoUrl?) ...[
          const SizedBox(height: AppSpacing.xs),
          Text('Part photo:', style: bodyStyle),
          const SizedBox(height: AppSpacing.xs),
          _EventPhoto(url: photoUrl),
        ],
      ],
      TripDetails() => [Text(_tripDetails(details), style: bodyStyle)],
    };
  }

  static List<String> _nonEmptyParts(MaintenanceDetails details) =>
      details.replacedParts
          ?.map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList(growable: false) ??
      const [];

  static String? _firstPhotoUrl(MaintenanceDetails details) {
    for (final url in details.photoUrls ?? const <String>[]) {
      if (url.trim().isNotEmpty) return url.trim();
    }

    return null;
  }

  static String _tripDetails(TripDetails details) {
    final route = details.route?.trim();
    final duration = _formatDuration(details.duration);

    return route == null || route.isEmpty ? duration : '$route • $duration';
  }
}

class _EventIcon extends StatelessWidget {
  final _EventPresentation presentation;

  const _EventIcon({required this.presentation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: presentation.iconBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: SvgPicture.asset(
        presentation.iconAsset,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(presentation.iconColor, BlendMode.srcIn),
      ),
    );
  }
}

class _EventTimestamp extends StatelessWidget {
  final DateTime occurredAt;

  const _EventTimestamp({required this.occurredAt});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            _formatDateTime(occurredAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _EventPhoto extends StatelessWidget {
  final String url;

  const _EventPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Image.network(
        url,
        width: 104,
        height: 128,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 104,
          height: 128,
          color: AppColors.surfaceHighest,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _EventPresentation {
  final String iconAsset;
  final Color iconColor;
  final Color iconBackground;
  final String? metric;

  const _EventPresentation({
    required this.iconAsset,
    required this.iconColor,
    required this.iconBackground,
    required this.metric,
  });

  factory _EventPresentation.from(HistoryEvent event) {
    return switch (event.type) {
      HistoryEventType.fuel => _EventPresentation(
        iconAsset: 'assets/icons/events/gas.svg',
        iconColor: AppColors.primaryLight,
        iconBackground: AppColors.primarySoft,
        metric: event.details is FuelDetails
            ? '${_formatNumber((event.details as FuelDetails).cost)} ₽'
            : null,
      ),
      HistoryEventType.maintenance => _EventPresentation(
        iconAsset: 'assets/icons/events/spanner.svg',
        iconColor: AppColors.error,
        iconBackground: AppColors.error.withValues(alpha: 0.14),
        metric: switch (event.details) {
          MaintenanceDetails(cost: final cost?) => '${_formatNumber(cost)} ₽',
          _ => null,
        },
      ),
      HistoryEventType.trip => _EventPresentation(
        iconAsset: 'assets/icons/events/trip.svg',
        iconColor: AppColors.textSecondary,
        iconBackground: AppColors.surfaceHighest,
        metric: event.details is TripDetails
            ? '${_formatNumber((event.details as TripDetails).distanceKm)} km'
            : null,
      ),
    };
  }
}

String _formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(digits[index]);
  }

  return value < 0 ? '-$buffer' : buffer.toString();
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours == 0) return '$minutes min';
  if (minutes == 0) return '$hours h';
  return '$hours h $minutes min';
}

String _formatDateTime(DateTime value) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '${months[local.month - 1]} ${local.day}, $hour:$minute';
}
