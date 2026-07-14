import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/localization/app_locale_controller.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/auth/di/auth_providers.dart';
import 'package:frontend/features/settings/presentation/utils/settings_localization_utils.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

void setSettingsLocale(WidgetRef ref, Locale locale) {
  unawaited(ref.read(appLocaleControllerProvider.notifier).setLocale(locale));
}

void openSettingsNotifications(BuildContext context) {
  unawaited(context.push<void>('/notifications'));
}

Future<void> logoutFromSettings(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final message = await ref.read(authControllerProvider.notifier).logout();
  if (message != null && context.mounted) {
    showNativeMessage(context, localizeSettingsError(l10n, message));
  }
}
