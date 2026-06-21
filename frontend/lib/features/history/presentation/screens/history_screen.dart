import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/history/presentation/providers/history_providers.dart';
import 'package:frontend/features/history/presentation/widgets/event_card.dart';
import 'package:go_router/go_router.dart';

final class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

final class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _query = '';
  HistoryEventType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(historyEventsProvider(widget.vehicleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance History')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push<HistoryEvent>(
            '/vehicle/${widget.vehicleId}/history/add',
          );
          if (mounted) {
            ref.invalidate(historyEventsProvider(widget.vehicleId));
          }
        },
        tooltip: 'Add event',
        backgroundColor: AppColors.primaryLight,
        foregroundColor: const Color(0xFF002388),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.add, size: 30),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                0,
              ),
              child: _SearchField(
                onChanged: (value) {
                  setState(() => _query = value.trim().toLowerCase());
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _TypeFilters(
              selectedType: _selectedType,
              onSelected: (type) {
                setState(() => _selectedType = type);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: eventsState.when(
                data: (events) {
                  final filteredEvents = _filterEvents(events);
                  if (filteredEvents.isEmpty) {
                    return _HistoryEmptyState(hasFilters: _hasFilters);
                  }

                  return _HistoryEventsList(events: filteredEvents);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _HistoryErrorState(
                  onRetry: () {
                    ref.invalidate(historyEventsProvider(widget.vehicleId));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasFilters => _query.isNotEmpty || _selectedType != null;

  List<HistoryEvent> _filterEvents(List<HistoryEvent> events) {
    return events
        .where((event) {
          final matchesType =
              _selectedType == null || event.type == _selectedType;
          final matchesQuery =
              _query.isEmpty || _searchableText(event).contains(_query);
          return matchesType && matchesQuery;
        })
        .toList(growable: false);
  }
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search history…',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

final class _TypeFilters extends StatelessWidget {
  const _TypeFilters({required this.selectedType, required this.onSelected});

  final HistoryEventType? selectedType;
  final ValueChanged<HistoryEventType?> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = <(String, HistoryEventType?)>[
      ('ALL', null),
      ('FUEL', HistoryEventType.fuel),
      ('REPAIRS', HistoryEventType.maintenance),
      ('TRIPS', HistoryEventType.trip),
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
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
                backgroundColor: isSelected
                    ? AppColors.primarySoft
                    : AppColors.surfaceHigh,
                overlayColor: Colors.transparent,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryPressed
                      : AppColors.border,
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
  const _HistoryEventsList({required this.events});

  final List<HistoryEvent> events;

  @override
  Widget build(BuildContext context) {
    final groups = _groupByMonth(events);

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
                  _monthTitle(group.month),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              for (var index = 0; index < group.events.length; index++) ...[
                EventCard(event: group.events[index]),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, color: AppColors.primaryLight, size: 48),
            const SizedBox(height: AppSpacing.lg),
            Text(
              hasFilters ? 'No events found' : 'History is empty',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilters
                  ? 'Try another search or event type.'
                  : 'Trips, refueling, and repairs will appear here.',
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not load history',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

String _searchableText(HistoryEvent event) {
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

List<_MonthGroup> _groupByMonth(List<HistoryEvent> events) {
  final sortedEvents = [...events]
    ..sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
  final groups = <_MonthGroup>[];

  for (final event in sortedEvents) {
    final month = DateTime(event.occurredAt.year, event.occurredAt.month);
    if (groups.isEmpty || groups.last.month != month) {
      groups.add(_MonthGroup(month: month, events: [event]));
    } else {
      groups.last.events.add(event);
    }
  }

  return groups;
}

String _monthTitle(DateTime month) {
  const months = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];

  return '${months[month.month - 1]} ${month.year}';
}

final class _MonthGroup {
  _MonthGroup({required this.month, required this.events});

  final DateTime month;
  final List<HistoryEvent> events;
}
