import 'package:frontend/features/analytics/domain/entities/analytics_period.dart';
import 'package:frontend/features/analytics/domain/entities/analytics_summary.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

String analyticsPeriodLabel(AppLocalizations l10n, AnalyticsPeriod period) {
  return switch (period) {
    AnalyticsPeriod.month => l10n.month,
    AnalyticsPeriod.year => l10n.yearPeriod,
    AnalyticsPeriod.all => l10n.allTime,
  };
}

String analyticsPeriodAdjective(AppLocalizations l10n, AnalyticsPeriod period) {
  return switch (period) {
    AnalyticsPeriod.month => l10n.monthly,
    AnalyticsPeriod.year => l10n.annual,
    AnalyticsPeriod.all => l10n.allTimeAdjective,
  };
}

String analyticsMonthName(AppLocalizations l10n, int month) {
  return switch (month) {
    1 => l10n.january,
    2 => l10n.february,
    3 => l10n.march,
    4 => l10n.april,
    5 => l10n.may,
    6 => l10n.june,
    7 => l10n.july,
    8 => l10n.august,
    9 => l10n.september,
    10 => l10n.october,
    11 => l10n.november,
    12 => l10n.december,
    _ => month.toString(),
  };
}

String analyticsLocalizedChartLabel(AppLocalizations l10n, String label) {
  final normalized = label.trim().toLowerCase();
  final parts = normalized.split(RegExp(r'\s+'));
  final leadingMonth = _monthNumber(parts.first);
  if (leadingMonth != null) {
    final monthLabel = _shortMonthName(l10n, leadingMonth);
    return parts.length > 1
        ? '$monthLabel ${parts.sublist(1).join(' ')}'
        : monthLabel;
  }

  final monthValue = int.tryParse(normalized);
  if (monthValue != null && monthValue >= 1 && monthValue <= 12) {
    return _shortMonthName(l10n, monthValue);
  }

  return switch (normalized) {
    'winter' => l10n.winter,
    'spring' => l10n.spring,
    'summer' => l10n.summer,
    'autumn' || 'fall' => l10n.autumn,
    _ => label,
  };
}

String _shortMonthName(AppLocalizations l10n, int month) {
  final name = analyticsMonthName(l10n, month);
  return name.length <= 3 ? name : name.substring(0, 3);
}

int? _monthNumber(String label) {
  return switch (label) {
    'jan' || 'january' => 1,
    'feb' || 'february' => 2,
    'mar' || 'march' => 3,
    'apr' || 'april' => 4,
    'may' => 5,
    'jun' || 'june' => 6,
    'jul' || 'july' => 7,
    'aug' || 'august' => 8,
    'sep' || 'september' => 9,
    'oct' || 'october' => 10,
    'nov' || 'november' => 11,
    'dec' || 'december' => 12,
    _ => null,
  };
}

String analyticsCategoryLabel(AppLocalizations l10n, ExpenseCategory category) {
  return switch (category) {
    ExpenseCategory.fuel => l10n.fuelCategory,
    ExpenseCategory.maintenance => l10n.maintenanceCategory,
    ExpenseCategory.parts => l10n.partsCategory,
    ExpenseCategory.other => l10n.otherCategory,
  };
}

String analyticsCompanyMetricLabel(AppLocalizations l10n, String label) {
  return switch (label.trim().toLowerCase()) {
    'events' => l10n.eventsMetric,
    'trip km' || 'trip kilometers' => l10n.tripKmMetric,
    'reliability' => l10n.reliabilityMetric,
    'efficiency' => l10n.efficiencyMetric,
    'maintenance load' => l10n.maintenanceLoadMetric,
    _ => label,
  };
}
