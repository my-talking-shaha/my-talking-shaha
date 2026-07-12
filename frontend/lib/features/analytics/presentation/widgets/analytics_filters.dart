import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/presentation/colors.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_formatters.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_labels.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class AnalyticsPeriodSelector extends StatelessWidget {
  const AnalyticsPeriodSelector({
    required this.selectedPeriod,
    required this.onSelected,
    super.key,
  });

  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final period in AnalyticsPeriod.values) ...[
          Expanded(
            child: Semantics(
              selected: selectedPeriod == period,
              child: TextButton(
                key: ValueKey('analytics-period-${period.queryValue}'),
                onPressed: () => onSelected(period),
                style: TextButton.styleFrom(
                  foregroundColor: selectedPeriod == period
                      ? AnalyticsColors.background
                      : AnalyticsColors.textSecondary,
                  backgroundColor: selectedPeriod == period
                      ? AnalyticsColors.primaryLight
                      : AnalyticsColors.surfaceHigh,
                  overlayColor: AnalyticsColors.transparent,
                  side: BorderSide(
                    color: selectedPeriod == period
                        ? AnalyticsColors.primaryLight
                        : AnalyticsColors.border,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.input,
                  ),
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                child: Text(
                  analyticsPeriodLabel(AppLocalizations.of(context), period),
                ),
              ),
            ),
          ),
          if (period != AnalyticsPeriod.values.last)
            const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

final class AnalyticsDateRangeSelector extends StatelessWidget {
  const AnalyticsDateRangeSelector({
    required this.selectedDateRange,
    required this.onSelect,
    required this.onClear,
    super.key,
  });

  final AnalyticsDateRange? selectedDateRange;
  final VoidCallback onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateRange = selectedDateRange;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            key: const ValueKey('analytics-custom-date-range'),
            onPressed: onSelect,
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: Text(
              dateRange == null
                  ? l10n.customRange
                  : analyticsDateRangeLabel(dateRange),
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: dateRange == null
                  ? AnalyticsColors.textSecondary
                  : AnalyticsColors.primaryLight,
              side: BorderSide(
                color: dateRange == null
                    ? AnalyticsColors.border
                    : AnalyticsColors.primaryLight,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.input,
              ),
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              textStyle: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        if (dateRange != null) ...[
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            key: const ValueKey('analytics-clear-date-range'),
            tooltip: l10n.clearCustomRange,
            onPressed: onClear,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              foregroundColor: AnalyticsColors.textSecondary,
              backgroundColor: AnalyticsColors.surfaceHigh,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.input,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

final class AnalyticsMileageFilterDropdown<T> extends StatelessWidget {
  const AnalyticsMileageFilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: AnalyticsColors.surfaceHigh,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AnalyticsColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AnalyticsColors.primaryLight),
        ),
      ),
      style: Theme.of(context).textTheme.labelMedium,
      iconEnabledColor: AnalyticsColors.textSecondary,
    );
  }
}
