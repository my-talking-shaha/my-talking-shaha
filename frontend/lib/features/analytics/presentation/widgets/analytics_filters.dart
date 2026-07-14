import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
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
                      ? context.appColors.background
                      : context.appColors.textSecondary,
                  backgroundColor: selectedPeriod == period
                      ? context.appColors.primaryLight
                      : context.appColors.surfaceHigh,
                  overlayColor: context.appColors.transparent,
                  side: BorderSide(
                    color: selectedPeriod == period
                        ? context.appColors.primaryLight
                        : context.appColors.border,
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
                  ? context.appColors.textSecondary
                  : context.appColors.primaryLight,
              side: BorderSide(
                color: dateRange == null
                    ? context.appColors.border
                    : context.appColors.primaryLight,
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
              foregroundColor: context.appColors.textSecondary,
              backgroundColor: context.appColors.surfaceHigh,
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
    this.title,
    super.key,
  });

  final T value;
  final List<NativePickerItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return NativeDropdownFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      title: title,
      dropdownColor: context.appColors.surfaceHigh,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: context.appColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: context.appColors.primaryLight),
        ),
      ),
      style: Theme.of(context).textTheme.labelMedium,
      iconColor: context.appColors.textSecondary,
    );
  }
}
