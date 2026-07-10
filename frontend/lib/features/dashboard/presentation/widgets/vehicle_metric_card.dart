import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/common/dashboard_card.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_text_style_utils.dart';

final class VehicleMetricCard extends StatelessWidget {
  const VehicleMetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    this.suffix,
    super.key,
  });

  final String label;
  final String value;
  final String subtitle;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      height: 132,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: DashboardTextStyleUtils.sectionLabel(context)),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 25),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    suffix!,
                    style: DashboardTextStyleUtils.sectionLabel(context),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
