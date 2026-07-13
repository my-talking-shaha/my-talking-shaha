import 'package:flutter/widgets.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

abstract final class AuthFormUtils {
  static String localizedErrorMessage(AppLocalizations l10n, String message) {
    return switch (message) {
      'Something went wrong. Please try again later' => l10n.somethingWentWrong,
      _ => message,
    };
  }

  static VoidCallback? enabledCallback({
    required bool isEnabled,
    required VoidCallback callback,
  }) {
    return isEnabled ? callback : null;
  }

  static void noOp() {}
}
