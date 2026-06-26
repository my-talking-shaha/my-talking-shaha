import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

final class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

final class _SettingsScreenState extends State<SettingsScreen> {
  String _theme = 'Dark';
  String _language = 'ENG';
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const _ProfileHeaderCard(
              fullName: 'Alex Driver',
              email: 'alex.driver@example.com',
            ),
            const SizedBox(height: AppSpacing.xl),
            _SettingsSection(
              title: 'Preferences',
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Theme',
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Dark', label: Text('Dark')),
                      ButtonSegment(value: 'Light', label: Text('Light')),
                    ],
                    selected: {_theme},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      setState(() {
                        _theme = selection.first;
                      });
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'ENG', label: Text('ENG')),
                      ButtonSegment(value: 'RU', label: Text('RU')),
                    ],
                    selected: {_language},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      setState(() {
                        _language = selection.first;
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
            const SizedBox(height: AppSpacing.xl),
            _SettingsSection(
              title: 'Notifications',
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
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              key: const ValueKey('profile_logout_action'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout will be connected with auth.'),
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceHighest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _initials(fullName),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryLight,
                    ),
              ),
            ),
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

final class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1)
                  const Divider(height: 1, indent: 56),
              ],
            ],
          ),
        ),
      ],
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
  });

  final Key? actionKey;
  final IconData icon;
  final String title;
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
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryLight),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child:
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(width: AppSpacing.md),
            trailing,
          ],
        ),
      ),
    );
  }
}
