import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/analytics/di/analytics_providers.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/mileage_trend.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_interactions.dart';
import 'package:frontend/features/analytics/presentation/widgets/analytics_dashboard.dart';
import 'package:frontend/features/analytics/presentation/widgets/analytics_states.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

final class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({
    required this.vehicleId,
    this.launchedFromChat = false,
    super.key,
  });

  final String vehicleId;
  final bool launchedFromChat;

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

final class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  static const _pollingInterval = Duration(seconds: 60);

  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.year;
  AnalyticsDateRange? _selectedDateRange;
  int _selectedMileageYear = DateTime.now().year;
  int? _selectedMileageMonth;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      if (!mounted) {
        return;
      }

      ref.invalidate(
        analyticsSummaryProvider((
          vehicleId: widget.vehicleId,
          period: _selectedPeriod,
          dateRange: _selectedDateRange,
        )),
      );
      ref.invalidate(
        mileageTrendProvider((
          vehicleId: widget.vehicleId,
          filter: MileageTrendFilter(
            year: _selectedMileageYear,
            month: _selectedMileageMonth,
          ),
        )),
      );
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = (
      vehicleId: widget.vehicleId,
      period: _selectedPeriod,
      dateRange: _selectedDateRange,
    );
    final l10n = AppLocalizations.of(context);
    final summaryState = ref.watch(analyticsSummaryProvider(request));
    final mileageTrendRequest = (
      vehicleId: widget.vehicleId,
      filter: MileageTrendFilter(
        year: _selectedMileageYear,
        month: _selectedMileageMonth,
      ),
    );
    final mileageTrendState = ref.watch(
      mileageTrendProvider(mileageTrendRequest),
    );

    return Scaffold(
      appBar: widget.launchedFromChat
          ? AppBar(
              leading: IconButton(
                onPressed: () =>
                    context.go('/vehicle/${widget.vehicleId}/chat'),
                tooltip: 'Back to chat',
                icon: const Icon(Icons.chevron_left_rounded, size: 32),
              ),
              title: Text(l10n.analytics),
            )
          : null,
      body: SafeArea(
        child: summaryState.when(
          data: (summary) {
            if (!summary.hasEnoughData) {
              return AnalyticsEmptyState(
                summary: summary,
                vehicleId: widget.vehicleId,
              );
            }

            return AnalyticsDashboard(
              summary: summary,
              vehicleId: widget.vehicleId,
              selectedPeriod: _selectedPeriod,
              selectedDateRange: _selectedDateRange,
              mileageTrendState: mileageTrendState,
              selectedMileageYear: _selectedMileageYear,
              selectedMileageMonth: _selectedMileageMonth,
              onPeriodSelected: (period) {
                setState(() {
                  _selectedPeriod = period;
                  _selectedDateRange = null;
                });
              },
              onDateRangeSelected: () async {
                final pickedRange = await selectAnalyticsDateRange(
                  context,
                  initialRange: _selectedDateRange,
                );
                if (pickedRange == null || !mounted) {
                  return;
                }
                setState(() => _selectedDateRange = pickedRange);
              },
              onDateRangeCleared: () {
                setState(() => _selectedDateRange = null);
              },
              onMileageYearSelected: (year) {
                setState(() => _selectedMileageYear = year);
              },
              onMileageMonthSelected: (month) {
                setState(() => _selectedMileageMonth = month);
              },
            );
          },
          loading: () => const AnalyticsLoadingState(),
          error: (error, stackTrace) => AnalyticsErrorState(
            onRetry: () {
              ref.invalidate(analyticsSummaryProvider(request));
              ref.invalidate(mileageTrendProvider(mileageTrendRequest));
            },
          ),
        ),
      ),
    );
  }
}
