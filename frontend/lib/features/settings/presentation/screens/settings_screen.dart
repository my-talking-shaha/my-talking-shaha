import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:go_router/go_router.dart';

final class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

final class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _theme = 'Dark';
  String _language = 'ENG';
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoggingOut = authState.isLoading && authState.hasValue;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
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
            const _ProfileHeaderCard(
              fullName: 'Alex Driver',
              email: 'alex.driver@example.com',
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _ThemeSection(
              selectedTheme: _theme,
              onChanged: (value) {
                setState(() {
                  _theme = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            _SettingsSection(
              title: 'General',
              children: [
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'App language',
                  subtitle: _language == 'ENG' ? 'English' : 'Russian',
                  trailing: _LanguageChoice(
                    selectedLanguage: _language,
                    onChanged: (value) {
                      setState(() {
                        _language = value;
                      });
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            _SettingsSection(
              title: 'Vehicle',
              children: [
                _SettingsTile(
                  actionKey: const ValueKey('profile_all_notifications_action'),
                  icon: Icons.notifications_active_outlined,
                  title: 'All notifications',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => context.push('/notifications'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoggingOut
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final message = await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (message != null) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                icon: isLoggingOut
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.fullName, required this.email});

  final String fullName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 104),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              _ProfileAvatar(initials: _initials(fullName)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(email, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}

final class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: borderColor ?? AppColors.border),
      ),
      child: child,
    );
  }
}

final class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceHighest,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            initials,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryLight,
                ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: 4,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.white,
              size: 11,
            ),
          ),
        ),
      ],
    );
  }
}

final class _ThemeSection extends StatelessWidget {
  const _ThemeSection({
    required this.selectedTheme,
    required this.onChanged,
  });

  final String selectedTheme;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Theme'),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.input,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _ThemeSegment(
                label: 'Light',
                selected: selectedTheme == 'Light',
                onTap: () => onChanged('Light'),
              ),
              _ThemeSegment(
                label: 'Dark',
                selected: selectedTheme == 'Dark',
                onTap: () => onChanged('Dark'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.input,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: AppRadius.input,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? AppColors.white : AppColors.textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}

final class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    required this.selectedLanguage,
    required this.onChanged,
  });

  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selectedLanguage,
      color: AppColors.surfaceHighest,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.input),
      onSelected: onChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'ENG', child: Text('ENG')),
        PopupMenuItem(value: 'RU', child: Text('RU')),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedLanguage,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

final class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(title),
        const SizedBox(height: AppSpacing.md),
        _SurfaceCard(
          child: Column(
            children: [
              for (final child in children) child,
            ],
          ),
        ),
      ],
    );
  }
}

final class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 1.8,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

final class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.actionKey,
    this.onTap,
    this.subtitle,
  });

  final Key? actionKey;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: actionKey,
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            trailing,
          ],
        ),
      ),
    );
  }
}
