import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/garage/presentation/controllers/power_output_unit_controller.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';
import 'package:frontend/features/garage/presentation/utils/garage_input_decoration.dart';
import 'package:frontend/features/garage/presentation/widgets/common/garage_field_label.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class GaragePowerOutputField extends StatelessWidget {
  const GaragePowerOutputField({
    required this.controller,
    required this.selectedUnit,
    required this.onUnitChanged,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final PowerOutputUnit selectedUnit;
  final ValueChanged<PowerOutputUnit> onUnitChanged;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GarageFieldLabel(label: l10n.powerOutput),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: const TextStyle(color: GarageColors.white, fontSize: 16),
          cursorColor: GarageColors.primaryLight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9,.]')),
          ],
          textInputAction: TextInputAction.done,
          decoration: garageInputDecoration(
            hintText: selectedUnit == PowerOutputUnit.kw ? '211' : '283',
            errorText: errorText,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _PowerOutputUnitToggle(
                selectedUnit: selectedUnit,
                onChanged: onUnitChanged,
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 124,
              minHeight: 44,
            ),
          ),
          onChanged: onChanged,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        ),
      ],
    );
  }
}

final class _PowerOutputUnitToggle extends StatelessWidget {
  const _PowerOutputUnitToggle({
    required this.selectedUnit,
    required this.onChanged,
  });

  final PowerOutputUnit selectedUnit;
  final ValueChanged<PowerOutputUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: GarageColors.formField,
          border: Border.all(color: GarageColors.formPrimary, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.5),
          child: Row(
            children: [
              _PowerOutputUnitOption(
                unit: PowerOutputUnit.hp,
                label: 'HP',
                isSelected: selectedUnit == PowerOutputUnit.hp,
                onChanged: onChanged,
              ),
              _PowerOutputUnitOption(
                unit: PowerOutputUnit.kw,
                label: 'kW',
                isSelected: selectedUnit == PowerOutputUnit.kw,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PowerOutputUnitOption extends StatelessWidget {
  const _PowerOutputUnitOption({
    required this.unit,
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });

  final PowerOutputUnit unit;
  final String label;
  final bool isSelected;
  final ValueChanged<PowerOutputUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isSelected ? GarageColors.formPrimary : GarageColors.transparent,
        child: InkWell(
          onTap: isSelected ? null : () => onChanged(unit),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? GarageColors.white : GarageColors.primaryLight,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
