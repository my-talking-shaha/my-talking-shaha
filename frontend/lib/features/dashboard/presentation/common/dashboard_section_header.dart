import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/utils/dashboard_text_style_utils.dart';

final class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: DashboardTextStyleUtils.sectionLabel(context),
          ),
        ),
        // ignore: use_null_aware_elements
        if (trailing != null) trailing!,
      ],
    );
  }
}
