import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/analytics/presentation/colors.dart';
import 'package:frontend/features/analytics/presentation/utils/analytics_formatters.dart';

final class AnalyticsDashboardCard extends StatelessWidget {
  const AnalyticsDashboardCard({
    required this.child,
    required this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AnalyticsColors.surfaceHigh,
            AnalyticsColors.surface,
            AnalyticsColors.backgroundDark,
          ],
        ),
        border: Border.all(color: AnalyticsColors.border),
        borderRadius: AppRadius.card,
      ),
      child: child,
    );
  }
}

final class AnalyticsSectionHeader extends StatelessWidget {
  const AnalyticsSectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AnalyticsColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AnalyticsColors.primaryLight,
            ),
          ),
      ],
    );
  }
}

final class AnalyticsTrendBadge extends StatelessWidget {
  const AnalyticsTrendBadge({required this.percent, super.key});

  final double percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AnalyticsColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up,
            color: AnalyticsColors.success,
            size: 14,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${formatAnalyticsDecimal(percent)}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AnalyticsColors.success,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

final class AnalyticsUnavailableText extends StatelessWidget {
  const AnalyticsUnavailableText({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AnalyticsColors.textMuted),
    );
  }
}

final class AnalyticsMetricBullet extends StatelessWidget {
  const AnalyticsMetricBullet({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AnalyticsColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: AnalyticsColors.textPrimary),
        ),
      ],
    );
  }
}
