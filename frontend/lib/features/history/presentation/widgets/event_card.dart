import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

part 'event_card_widgets.dart';

class EventCard extends StatefulWidget {
  final HistoryEvent event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({required this.event, this.onEdit, this.onDelete, super.key});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with TickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(covariant EventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.id != widget.event.id) {
      _isExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final details = event.details;
    final presentation = _EventPresentation.from(context, event);
    final photoUrls = _photoUrls(details);
    final l10n = AppLocalizations.of(context);

    return _HistorySwipeRevealActions(
      actions: [
        if (widget.onEdit != null)
          _HistorySwipeActionButton(
            actionKey: 'edit',
            label: l10n.edit,
            iconPath: 'assets/icons/garage/edit.svg',
            color: context.appColors.warningStrong,
            onPressed: widget.onEdit!,
          ),
        if (widget.onDelete != null)
          _HistorySwipeActionButton(
            actionKey: 'delete',
            label: l10n.delete,
            iconPath: 'assets/icons/garage/delete.svg',
            color: context.appColors.destructive,
            onPressed: widget.onDelete!,
          ),
      ],
      child: GestureDetector(
        onTap: photoUrls.isEmpty
            ? null
            : () => setState(() => _isExpanded = !_isExpanded),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            border: Border.all(color: context.appColors.border),
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
                                ?.copyWith(color: context.appColors.primary),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ..._detailWidgets(context, details),
                    const SizedBox(height: AppSpacing.xs),
                    _EventTimestamp(occurredAt: event.occurredAt),
                    if (photoUrls.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _PhotoToggle(
                        count: photoUrls.length,
                        isExpanded: _isExpanded,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: _isExpanded
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sm,
                                ),
                                child: _EventPhotoList(urls: photoUrls),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _detailWidgets(BuildContext context, EventDetails details) {
    final l10n = AppLocalizations.of(context);
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return switch (details) {
      FuelDetails() => [
        Text(
          '${_formatFuelAmount(details)} • ${details.fuelType}',
          style: bodyStyle,
        ),
      ],
      MaintenanceDetails() => [
        if (details.description.trim().isNotEmpty)
          Text(details.description, style: bodyStyle),
        if (_nonEmptyParts(details).isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.replaced(_nonEmptyParts(details).join(', ')),
            style: bodyStyle,
          ),
        ],
      ],
      TripDetails() => [Text(_tripDetails(context, details), style: bodyStyle)],
    };
  }

  static List<String> _photoUrls(EventDetails details) {
    if (details is! MaintenanceDetails) return const [];

    return (details.photoUrls ?? const <String>[])
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _nonEmptyParts(MaintenanceDetails details) =>
      details.replacedParts
          ?.map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList(growable: false) ??
      const [];

  static String _tripDetails(BuildContext context, TripDetails details) {
    final route = details.route?.trim();
    final duration = _formatDuration(context, details.duration);

    return route == null || route.isEmpty ? duration : '$route • $duration';
  }
}
