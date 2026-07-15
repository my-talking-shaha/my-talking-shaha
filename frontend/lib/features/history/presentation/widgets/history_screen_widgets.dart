part of '../screens/history_screen.dart';

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.searchHistory,
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}

final class _TypeFilters extends StatelessWidget {
  const _TypeFilters({
    required this.selectedType,
    required this.onSelected,
    required this.isElectricVehicle,
  });

  final HistoryEventType? selectedType;
  final ValueChanged<HistoryEventType?> onSelected;
  final bool isElectricVehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = <(String, HistoryEventType?)>[
      (l10n.all, null),
      (isElectricVehicle ? l10n.charge : l10n.fuel, HistoryEventType.fuel),
      (l10n.repairs, HistoryEventType.maintenance),
      (l10n.partsCategory.toUpperCase(), HistoryEventType.part),
      (l10n.trips, HistoryEventType.trip),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final (label, type) = filters[index];
          final isSelected = selectedType == type;

          return Semantics(
            selected: isSelected,
            child: TextButton(
              onPressed: () => onSelected(type),
              style: TextButton.styleFrom(
                foregroundColor: isSelected
                    ? context.appColors.primary
                    : context.appColors.textSecondary,
                backgroundColor: isSelected
                    ? context.appColors.primarySoft
                    : context.appColors.surface,
                overlayColor: context.appColors.transparent,
                side: BorderSide(
                  color: isSelected
                      ? context.appColors.primaryPressed
                      : context.appColors.border,
                ),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                animationDuration: Duration.zero,
                splashFactory: NoSplash.splashFactory,
                textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              child: Text(label),
            ),
          );
        },
      ),
    );
  }
}

final class _HistoryEventsList extends StatelessWidget {
  const _HistoryEventsList({
    required this.events,
    required this.cardStateRevision,
    required this.onEditEvent,
    required this.onDeleteEvent,
  });

  final List<HistoryEvent> events;
  final int cardStateRevision;
  final ValueChanged<HistoryEvent> onEditEvent;
  final ValueChanged<HistoryEvent> onDeleteEvent;

  @override
  Widget build(BuildContext context) {
    final groups = HistoryTimelineUtils.groupByMonth(events);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];

        return Padding(
          padding: EdgeInsets.only(
            bottom: groupIndex == groups.length - 1 ? 0 : AppSpacing.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.sm,
                  bottom: AppSpacing.md,
                ),
                child: Text(
                  HistoryTimelineUtils.monthTitle(context, group.month),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.appColors.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              for (var index = 0; index < group.events.length; index++) ...[
                EventCard(
                  key: ValueKey(
                    'history_event_${group.events[index].id}_'
                    '$cardStateRevision',
                  ),
                  event: group.events[index],
                  onEdit: () => onEditEvent(group.events[index]),
                  onDelete: () => onDeleteEvent(group.events[index]),
                ),
                if (index < group.events.length - 1)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        );
      },
    );
  }
}

final class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({required this.hasFilters});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: context.appColors.primary, size: 48),
            const SizedBox(height: AppSpacing.lg),
            Text(
              hasFilters ? l10n.noEventsFound : l10n.historyEmpty,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilters ? l10n.tryAnotherSearch : l10n.historyEmptyDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

final class _HistoryErrorState extends StatelessWidget {
  const _HistoryErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.couldNotLoadHistory,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
