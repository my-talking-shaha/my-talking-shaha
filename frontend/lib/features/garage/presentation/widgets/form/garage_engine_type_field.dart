import 'package:flutter/material.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';
import 'package:frontend/features/garage/presentation/utils/garage_engine_type_utils.dart';
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
        PopupMenuButton<String>(
          enabled: onChanged != null,
          color: GarageColors.formField,
          elevation: 8,
          onOpened: () => FocusScope.of(context).unfocus(),
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: GarageColors.formBorder),
          ),
          onSelected: onChanged,
          itemBuilder: (context) => [
            garageEngineTypeMenuItem(l10n, 'gasoline'),
            garageEngineTypeMenuItem(l10n, 'diesel'),
            garageEngineTypeMenuItem(l10n, 'hybrid'),
            garageEngineTypeMenuItem(l10n, 'phev'),
            garageEngineTypeMenuItem(l10n, 'electric'),
          ],
          child: InputDecorator(
            decoration: InputDecoration(
              errorText: errorText,
              filled: true,
              fillColor: GarageColors.formField,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError
                      ? GarageColors.error
                      : GarageColors.formBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: GarageColors.primaryLight),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: GarageColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: GarageColors.error),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valueText,
                    style: TextStyle(
                      color: selectedValue.isEmpty
                          ? GarageColors.hint
                          : GarageColors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: GarageColors.primaryLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
