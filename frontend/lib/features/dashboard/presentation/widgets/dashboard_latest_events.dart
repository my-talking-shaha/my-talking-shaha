import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_utils.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:go_router/go_router.dart';

final class DashboardLatestEvents extends StatelessWidget {
  const DashboardLatestEvents({
    required this.vehicleId,
    required this.eventsState,
    super.key,
  });

  final String vehicleId;
  final AsyncValue<List<HistoryEvent>> eventsState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'LATEST EVENTS',
          trailing: TextButton(
            onPressed: () => context.go('/vehicle/$vehicleId/history'),
            child: const Text('View all'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        eventsState.when(
          data: (events) {
            if (events.isEmpty) {
              return const _EventsMessage(message: 'No events yet');
            }

            final latestEvents = events.take(5).toList(growable: false);
            return Column(
              children: [
                for (var index = 0; index < latestEvents.length; index++) ...[
                  _RecentEventTile(event: latestEvents[index]),
                  if (index < latestEvents.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
          loading: () => const _EventsMessage(
            message: 'Loading recent events...',
            showProgress: true,
          ),
          error: (error, stackTrace) =>
              const _EventsMessage(message: 'Recent events are unavailable'),
        ),
      ],
    );
  }
}

final class _RecentEventTile extends StatelessWidget {
  const _RecentEventTile({required this.event});

  final HistoryEvent event;

  @override
  Widget build(BuildContext context) {
    final presentation = _RecentEventPresentation.from(event.type);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: presentation.backgroundColor,
            ),
            child: SvgPicture.asset(
              presentation.assetPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                presentation.iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DashboardUtils.eventSubtitle(event),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            DashboardUtils.relativeDate(event.occurredAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

final class _EventsMessage extends StatelessWidget {
  const _EventsMessage({required this.message, this.showProgress = false});

  final String message;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (showProgress) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

final class _RecentEventPresentation {
  const _RecentEventPresentation({
    required this.assetPath,
    required this.iconColor,
    required this.backgroundColor,
  });

  final String assetPath;
  final Color iconColor;
  final Color backgroundColor;

  factory _RecentEventPresentation.from(HistoryEventType type) {
    return switch (type) {
      HistoryEventType.fuel => const _RecentEventPresentation(
        assetPath: 'assets/icons/events/gas.svg',
        iconColor: AppColors.warning,
        backgroundColor: Color(0xFF30291F),
      ),
      HistoryEventType.maintenance => const _RecentEventPresentation(
        assetPath: 'assets/icons/events/spanner.svg',
        iconColor: AppColors.success,
        backgroundColor: Color(0xFF123138),
      ),
      HistoryEventType.trip => const _RecentEventPresentation(
        assetPath: 'assets/icons/events/trip.svg',
        iconColor: AppColors.primaryLight,
        backgroundColor: AppColors.surfaceHighest,
      ),
    };
  }
}
