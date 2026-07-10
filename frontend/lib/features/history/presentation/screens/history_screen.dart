import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/providers/vehicle_mileage_provider.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/di/analytics_providers.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/dashboard/di/dashboard_providers.dart';
import 'package:frontend/features/garage/di/garage_providers.dart';
import 'package:frontend/features/history/domain/entities/event_details.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/features/history/domain/entities/history_event_type.dart';
import 'package:frontend/features/history/presentation/providers/history_providers.dart';
import 'package:frontend/features/history/presentation/widgets/event_card.dart';
import 'package:frontend/features/parts/di/parts_providers.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

part 'history_screen_widgets.dart';

final class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({
    required this.vehicleId,
    this.launchedFromChat = false,
    super.key,
  });

  final String vehicleId;
  final bool launchedFromChat;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

final class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _query = '';
  HistoryEventType? _selectedType;
  int _cardStateRevision = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final eventsState = ref.watch(historyEventsProvider(widget.vehicleId));
    final engineTypeState = ref.watch(
      vehicleEngineTypeProvider(widget.vehicleId),
    );
    final isElectricVehicle = engineTypeState.maybeWhen(
      data: (engineType) => _isElectricEngine(engineType),
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        leading: widget.launchedFromChat
            ? IconButton(
                onPressed: () =>
                    context.go('/vehicle/${widget.vehicleId}/chat'),
                tooltip: l10n.backToChat,
                icon: const Icon(Icons.chevron_left_rounded, size: 32),
              )
            : null,
        title: Text(l10n.maintenanceHistory),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final event = await context.push<HistoryEvent>(
            '/vehicle/${widget.vehicleId}/history/add',
          );
          if (!mounted) return;
          if (event != null) {
            _invalidateAfterHistoryMutation(affectsMileage: true);
            _showSuccessMessage(l10n.eventAdded);
          }
        },
        tooltip: l10n.addEvent,
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
              isElectricVehicle: isElectricVehicle,
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

                  return _HistoryEventsList(
                    events: filteredEvents,
                    cardStateRevision: _cardStateRevision,
                    onEditEvent: _editEvent,
                    onDeleteEvent: (event) {
                      unawaited(_confirmDelete(event));
                    },
                  );
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

  Future<void> _editEvent(HistoryEvent event) async {
    final updatedEvent = await context.push<HistoryEvent>(
      '/vehicle/${widget.vehicleId}/history/${event.id}/edit',
      extra: event,
    );
    if (!mounted) return;
    setState(() => _cardStateRevision++);
    if (updatedEvent != null) {
      _invalidateAfterHistoryMutation(affectsMileage: true);
      _showSuccessMessage(AppLocalizations.of(context).eventUpdated);
    }
  }

  Future<void> _confirmDelete(HistoryEvent event) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteEventQuestion),
          content: Text(l10n.deleteEventConfirmation(event.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref
          .read(deleteHistoryEventProvider)
          .call(widget.vehicleId, event.id);
      await ref.read(deleteHistoryPhotoCacheProvider)(event);
      if (!mounted) return;
      _invalidateAfterHistoryMutation(affectsMileage: false);
      setState(() => _cardStateRevision++);
      _showSuccessMessage(l10n.eventDeleted);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.couldNotDeleteEvent)));
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _invalidateAfterHistoryMutation({required bool affectsMileage}) {
    final vehicleId = widget.vehicleId;
    ref.invalidate(historyEventsProvider(vehicleId));
    ref.invalidate(vehicleDashboardProvider(vehicleId));
    for (final period in AnalyticsPeriod.values) {
      ref.invalidate(
        analyticsSummaryProvider((
          vehicleId: vehicleId,
          period: period,
          dateRange: null,
        )),
      );
    }

    if (!affectsMileage) {
      return;
    }

    ref.invalidate(garageControllerProvider);
    ref.invalidate(vehicleMileageProvider(vehicleId));
    ref.invalidate(vehiclePartsProvider(vehicleId));
  }
}

bool _isElectricEngine(String? engineType) {
  return engineType?.toLowerCase() == 'electric';
}
