import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/settings/presentation/utils/settings_localization_utils.dart';

final class SettingsLanguageChoice extends StatelessWidget {
  const SettingsLanguageChoice({
    required this.selectedLocale,
    required this.englishLabel,
    required this.russianLabel,
    required this.onChanged,
    super.key,
  });

  final Locale selectedLocale;
  final String englishLabel;
  final String russianLabel;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      initialValue: selectedLocale,
      color: context.appColors.surfaceHighest,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.input),
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Text('$englishLabel (EN)'),
        ),
        PopupMenuItem(
          value: const Locale('ru'),
          child: Text('$russianLabel (RU)'),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            settingsLanguageCode(selectedLocale),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.chevron_right_rounded, color: context.appColors.textMuted),
        ],
      ),
    );
  }
}
