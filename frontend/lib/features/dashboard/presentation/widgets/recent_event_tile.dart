import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:frontend/features/dashboard/presentation/common/dashboard_card.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_event_presentation.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_formatters.dart';

final class RecentEventTile extends StatelessWidget {
  const RecentEventTile({required this.event, super.key});

  final DashboardRecentEvent event;

  @override
  Widget build(BuildContext context) {
    final presentation = DashboardEventPresentation.from(
      event.type,
      colors: context.appColors,
    );

    return DashboardCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: presentation.backgroundColor,
            ),
            child: SvgPicture.asset(
              presentation.assetPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                presentation.iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  event.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            DashboardFormatters.relativeDate(context, event.occurredAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
