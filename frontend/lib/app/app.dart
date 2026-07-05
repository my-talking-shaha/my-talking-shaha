import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/localization/app_locale_controller.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

class CarApp extends ConsumerWidget {
  const CarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale =
        ref
            .watch(appLocaleControllerProvider)
            .maybeWhen(data: (locale) => locale, orElse: () => null) ??
        const Locale('en');

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocaleController.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
