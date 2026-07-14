import 'package:flutter/material.dart';
import 'package:frontend/core/ui/native_ui.dart';

final class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({
    required this.isLoggingOut,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final bool isLoggingOut;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoggingOut ? null : onPressed,
        icon: isLoggingOut
            ? const SizedBox.square(
                dimension: 18,
                child: NativeActivityIndicator(strokeWidth: 2, radius: 9),
              )
            : const Icon(Icons.logout),
        label: Text(label),
      ),
    );
  }
}
