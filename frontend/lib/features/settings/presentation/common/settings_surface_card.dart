import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/settings/presentation/colors.dart';

final class SettingsSurfaceCard extends StatelessWidget {
  const SettingsSurfaceCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: SettingsColors.border),
      ),
      child: child,
    );
  }
}
