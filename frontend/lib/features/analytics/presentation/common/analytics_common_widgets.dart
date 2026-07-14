import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.appColors.surfaceHigh,
            context.appColors.surface,
            context.appColors.backgroundDark,
          ],
        ),
        border: Border.all(color: context.appColors.border),
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
              color: context.appColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.appColors.primaryLight,
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
        color: context.appColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, color: context.appColors.success, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${formatAnalyticsDecimal(percent)}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.appColors.success,
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
      ).textTheme.bodyMedium?.copyWith(color: context.appColors.textMuted),
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.appColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: context.appColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
