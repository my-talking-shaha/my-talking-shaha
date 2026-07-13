import 'package:flutter/widgets.dart';
import 'package:frontend/features/auth/presentation/common/auth_mode_switch.dart';
import 'package:go_router/go_router.dart';

abstract final class AuthNavigation {
  static VoidCallback goToLoginCallback(BuildContext context) {
    return () => context.go('/login');
  }

  static VoidCallback goToRegistrationCallback(BuildContext context) {
    return () => context.go('/registration');
  }

  static ValueChanged<AuthMode> modeSelectionCallback(
    BuildContext context,
    AuthMode currentMode,
  ) {
    return (mode) {
      if (mode == currentMode) return;

      switch (mode) {
        case AuthMode.login:
          context.go('/login');
        case AuthMode.register:
          context.go('/registration');
      }
    };
  }
}
