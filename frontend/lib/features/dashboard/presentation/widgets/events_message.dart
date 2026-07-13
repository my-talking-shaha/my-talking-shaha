import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/common/dashboard_card.dart';

final class EventsMessage extends StatelessWidget {
  const EventsMessage({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DashboardCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
