import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/garage/presentation/utils/garage_form_utils.dart';
import 'package:frontend/features/garage/presentation/utils/garage_input_decoration.dart';
import 'package:frontend/features/garage/presentation/widgets/common/garage_field_label.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class GarageColorField extends StatelessWidget {
  const GarageColorField({
    required this.controller,
    required this.focusNode,
    required this.colors,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> colors;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GarageFieldLabel(label: l10n.color),
        const SizedBox(height: 10),
        RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: focusNode,
          displayStringForOption: (color) =>
              localizedGarageVehicleColor(l10n, color),
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) {
              return const Iterable<String>.empty();
            }

            return colors.where((color) {
              return color.toLowerCase().contains(query) ||
                  localizedGarageVehicleColor(
                    l10n,
                    color,
                  ).toLowerCase().contains(query);
            });
          },
          onSelected: (color) {
            controller.text = localizedGarageVehicleColor(l10n, color);
            onChanged(color);
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  key: const ValueKey('vehicle_color_field'),
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 16,
                  ),
                  cursorColor: context.appColors.primaryLight,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: garageInputDecoration(
                    context: context,
                    hintText: l10n.selectColor,
                    suffixIcon: Icon(
                      Icons.search,
                      color: context.appColors.primaryLight,
                    ),
                  ),
                  onChanged: onChanged,
                  onSubmitted: (_) => onFieldSubmitted(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            return NativeAutocompleteOptions<String>(
              options: options,
              labelBuilder: (color) => localizedGarageVehicleColor(l10n, color),
              onSelected: onSelected,
              backgroundColor: context.appColors.formField,
              textStyle: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 16,
              ),
            );
          },
        ),
      ],
    );
  }
}
