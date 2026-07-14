import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/garage/presentation/utils/garage_form_utils.dart';
import 'package:frontend/features/garage/presentation/widgets/common/garage_field_label.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class GarageEngineTypeField extends StatelessWidget {
  const GarageEngineTypeField({
    required this.selectedValue,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final String selectedValue;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valueText = selectedValue.isEmpty
        ? l10n.selectEngineType
        : localizedGarageEngineType(l10n, selectedValue);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GarageFieldLabel(label: l10n.engineType),
        const SizedBox(height: 10),
        NativePopupMenuButton<String>(
          enabled: onChanged != null,
          color: context.appColors.formField,
          elevation: 8,
          onOpened: () => FocusScope.of(context).unfocus(),
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: context.appColors.formBorder),
          ),
          selectedValue: selectedValue.isEmpty ? null : selectedValue,
          title: l10n.engineType,
          textStyle: TextStyle(color: context.appColors.textPrimary),
          onSelected: (value) => onChanged?.call(value),
          items: [
            for (final value in const [
              'gasoline',
              'diesel',
              'hybrid',
              'phev',
              'electric',
            ])
              NativePickerItem(
                value: value,
                label: localizedGarageEngineType(l10n, value),
              ),
          ],
          child: InputDecorator(
            decoration: InputDecoration(
              errorText: errorText,
              filled: true,
              fillColor: context.appColors.formField,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError
                      ? context.appColors.error
                      : context.appColors.formBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.appColors.primaryLight),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.appColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.appColors.error),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valueText,
                    style: TextStyle(
                      color: selectedValue.isEmpty
                          ? context.appColors.hint
                          : context.appColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.appColors.primaryLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
