import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/utils/auth_mode_style_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

enum AuthMode { login, register }

final class AuthModeSwitch extends StatelessWidget {
  const AuthModeSwitch({
    required this.selectedMode,
    required this.onModeSelected,
    super.key,
  });

  final AuthMode selectedMode;
  final ValueChanged<AuthMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SegmentedButton<AuthMode>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment<AuthMode>(
          value: AuthMode.login,
          icon: const Icon(Icons.login_outlined),
          label: Text(l10n.logIn),
        ),
        ButtonSegment<AuthMode>(
          value: AuthMode.register,
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: Text(l10n.register),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged: AuthModeStyleUtils.selectionHandler(onModeSelected),
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        side: WidgetStateProperty.resolveWith(
          (states) => AuthModeStyleUtils.borderSide(context, states),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => AuthModeStyleUtils.foregroundColor(context, states),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => AuthModeStyleUtils.backgroundColor(context, states),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
