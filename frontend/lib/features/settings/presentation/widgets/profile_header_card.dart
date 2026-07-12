import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/settings/presentation/colors.dart';
import 'package:frontend/features/settings/presentation/common/settings_surface_card.dart';
import 'package:frontend/features/settings/presentation/utils/settings_profile_utils.dart';

final class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.fullName,
    required this.login,
    super.key,
  });

  final String fullName;
  final String login;

  @override
  Widget build(BuildContext context) {
    return SettingsSurfaceCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 104),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              _ProfileAvatar(initials: settingsInitials(fullName)),
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
                    Text(login, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
            color: SettingsColors.surfaceHighest,
            shape: BoxShape.circle,
            border: Border.all(color: SettingsColors.border),
          ),
          child: Text(
            initials,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: SettingsColors.primaryLight,
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
              color: SettingsColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: SettingsColors.surface, width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: SettingsColors.white,
              size: 11,
            ),
          ),
        ),
      ],
    );
  }
}
