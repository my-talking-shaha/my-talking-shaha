import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/settings/presentation/common/settings_section.dart';

final class SettingsThemeSection extends StatelessWidget {
  const SettingsThemeSection({
    required this.selectedTheme,
    required this.lightLabel,
    required this.darkLabel,
    required this.title,
    required this.onChanged,
    super.key,
  });

  final String selectedTheme;
  final String lightLabel;
  final String darkLabel;
  final String title;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(title),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.input,
            border: Border.all(color: context.appColors.border),
          ),
          child: Row(
            children: [
              _ThemeSegment(
                label: lightLabel,
                selected: selectedTheme == 'light',
                onTap: () => onChanged('light'),
              ),
              _ThemeSegment(
                label: darkLabel,
                selected: selectedTheme == 'dark',
                onTap: () => onChanged('dark'),
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
            color: selected
                ? context.appColors.primary
                : context.appColors.transparent,
            borderRadius: AppRadius.input,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected
                  ? context.appColors.white
                  : context.appColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
