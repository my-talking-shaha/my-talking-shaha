import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class AuthFormCard extends StatelessWidget {
  const AuthFormCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 350),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.appColors.formBorder),
        boxShadow: [
          BoxShadow(
            color: context.appColors.black.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}
