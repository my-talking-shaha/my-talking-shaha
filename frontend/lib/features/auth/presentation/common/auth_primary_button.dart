import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.showArrow = false,
    super.key,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  if (showArrow) ...[
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.arrow_forward, size: 22),
                  ],
                ],
              ),
      ),
    );
  }
}
