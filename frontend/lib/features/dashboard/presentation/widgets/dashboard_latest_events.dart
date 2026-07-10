import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:frontend/features/dashboard/presentation/common/dashboard_section_header.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_actions.dart';
import 'package:frontend/features/dashboard/presentation/widgets/events_message.dart';
import 'package:frontend/features/dashboard/presentation/widgets/recent_event_tile.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class DashboardLatestEvents extends StatelessWidget {
  const DashboardLatestEvents({
    required this.vehicleId,
    required this.events,
    super.key,
  });

  final String vehicleId;
  final List<DashboardRecentEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: l10n.latestEvents,
          trailing: TextButton(
            onPressed: () => DashboardActions.openHistory(context, vehicleId),
            child: Text(l10n.viewAll),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (events.isEmpty)
          EventsMessage(message: l10n.noEventsYet)
        else
          Column(
            children: [
              for (var index = 0; index < events.length; index++) ...[
                RecentEventTile(event: events[index]),
                if (index < events.length - 1)
                  const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
      ],
    );
  }
}
