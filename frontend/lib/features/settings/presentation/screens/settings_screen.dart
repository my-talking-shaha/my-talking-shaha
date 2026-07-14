import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/localization/app_locale_controller.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/app/theme/app_theme_controller.dart';
import 'package:frontend/features/auth/di/auth_providers.dart';
import 'package:frontend/features/settings/presentation/common/settings_section.dart';
import 'package:frontend/features/settings/presentation/common/settings_tile.dart';
import 'package:frontend/features/settings/presentation/utils/settings_actions.dart';
import 'package:frontend/features/settings/presentation/utils/settings_profile_utils.dart';
import 'package:frontend/features/settings/presentation/widgets/profile_header_card.dart';
import 'package:frontend/features/settings/presentation/widgets/settings_language_choice.dart';
import 'package:frontend/features/settings/presentation/widgets/settings_logout_button.dart';
import 'package:frontend/features/settings/presentation/widgets/settings_theme_section.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

final class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final themeMode =
        ref
            .watch(appThemeControllerProvider)
            .maybeWhen(data: (themeMode) => themeMode, orElse: () => null) ??
        ThemeMode.dark;
    final locale =
        ref
            .watch(appLocaleControllerProvider)
            .maybeWhen(data: (locale) => locale, orElse: () => null) ??
        const Locale('en');
    final session = authState.maybeWhen(
      data: (session) => session,
      orElse: () => null,
    );
    final profileName = settingsProfileName(
      fullName: session?.fullName,
      login: session?.login,
      fallback: l10n.driver,
    );
    final profileLogin = settingsProfileLogin(
      login: session?.login,
      fallback: l10n.signedIn,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.profile,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          children: [
            ProfileHeaderCard(fullName: profileName, login: profileLogin),
            const SizedBox(height: AppSpacing.xxxl),
            SettingsThemeSection(
              selectedTheme: themeMode.name,
              lightLabel: l10n.light,
              darkLabel: l10n.dark,
              title: l10n.theme,
              onChanged: (value) => ref
                  .read(appThemeControllerProvider.notifier)
                  .setThemeMode(
                    value == ThemeMode.light.name
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SettingsSection(
              title: l10n.general,
              children: [
                SettingsTile(
                  icon: Icons.language_rounded,
                  title: l10n.appLanguage,
                  subtitle: locale.languageCode == 'ru'
                      ? l10n.russian
                      : l10n.english,
                  trailing: SettingsLanguageChoice(
                    selectedLocale: locale,
                    englishLabel: l10n.english,
                    russianLabel: l10n.russian,
                    onChanged: (value) => setSettingsLocale(ref, value),
                  ),
                ),
                SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: l10n.notifications,
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            SettingsSection(
              title: l10n.vehicle,
              children: [
                SettingsTile(
                  actionKey: const ValueKey('profile_all_notifications_action'),
                  icon: Icons.notifications_active_outlined,
                  title: l10n.allNotifications,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: context.appColors.textMuted,
                  ),
                  onTap: () => openSettingsNotifications(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
            SettingsLogoutButton(
              isLoggingOut: authState.isLoading && authState.hasValue,
              label: l10n.logOut,
              onPressed: () => logoutFromSettings(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
