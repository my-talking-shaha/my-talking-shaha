import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class NotificationCenteredText extends StatelessWidget {
  const NotificationCenteredText({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(text),
      ),
    );
  }
}
