import 'package:frontend/l10n/generated/app_localizations.dart';

abstract final class AuthValidator {
  static const int minPasswordLength = 6;

  static String? fullName(String? value, AppLocalizations l10n) {
    return requiredField(value, message: l10n.enterYourFullName);
  }

  static String? login(String? value, AppLocalizations l10n) {
    final requiredError = requiredField(value, message: l10n.enterYourEmail);
    if (requiredError != null) {
      return requiredError;
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return l10n.enterValidEmail;
    }

    return null;
  }

  static String? password(String? value, AppLocalizations l10n) {
    final requiredError = requiredField(value, message: l10n.enterYourPassword);
    if (requiredError != null) {
      return requiredError;
    }

    if (!isStrongPassword(value!)) {
      return l10n.passwordMinLength(minPasswordLength);
    }

    return null;
  }

  static String? confirmPassword(
    String? value,
    String password,
    AppLocalizations l10n,
  ) {
    final requiredError = requiredField(
      value,
      message: l10n.confirmYourPassword,
    );
    if (requiredError != null) {
      return requiredError;
    }

    if (value != password) {
      return l10n.passwordsDoNotMatch;
    }

    return null;
  }

  static String? requiredField(String? value, {required String message}) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  static bool isStrongPassword(String password) {
    return password.trim().length >= minPasswordLength;
  }
}
