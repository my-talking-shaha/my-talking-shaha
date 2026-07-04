import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/storage/shared_preferences_provider.dart';

final appLocaleControllerProvider =
    AsyncNotifierProvider<AppLocaleController, Locale>(
      AppLocaleController.new,
      retry: (_, _) => null,
    );

final class AppLocaleController extends AsyncNotifier<Locale> {
  static const _languageCodeKey = 'app_language_code';
  static const supportedLocales = [Locale('en'), Locale('ru')];

  @override
  Future<Locale> build() async {
    final savedLanguageCode = await ref
        .watch(sharedPreferencesProvider)
        .getString(_languageCodeKey);
    return _localeFromLanguageCode(savedLanguageCode);
  }

  Future<void> setLocale(Locale locale) async {
    final normalizedLocale = _localeFromLanguageCode(locale.languageCode);
    state = AsyncData(normalizedLocale);
    await ref
        .read(sharedPreferencesProvider)
        .setString(_languageCodeKey, normalizedLocale.languageCode);
  }

  Locale _localeFromLanguageCode(String? languageCode) {
    return switch (languageCode) {
      'ru' => const Locale('ru'),
      _ => const Locale('en'),
    };
  }
}
