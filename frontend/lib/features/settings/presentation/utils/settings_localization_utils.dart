import 'dart:ui';

import 'package:frontend/l10n/generated/app_localizations.dart';

String settingsLanguageCode(Locale locale) {
  return locale.languageCode == 'ru' ? 'RU' : 'EN';
}

String localizeSettingsError(AppLocalizations l10n, String message) {
  return switch (message) {
    'Could not log out. Please try again' => l10n.couldNotLogOut,
    _ => message,
  };
}
