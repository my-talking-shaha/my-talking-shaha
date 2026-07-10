import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';
import 'package:frontend/features/garage/presentation/utils/garage_input_decoration.dart';
import 'package:frontend/features/garage/presentation/widgets/common/garage_field_label.dart';

final class GarageTextField extends StatelessWidget {
  const GarageTextField({
    required this.label,
    required this.hintText,
    required this.onChanged,
    required this.controller,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    super.key,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GarageFieldLabel(label: label),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: const TextStyle(color: GarageColors.white, fontSize: 16),
          cursorColor: GarageColors.primaryLight,
          decoration: garageInputDecoration(
            hintText: hintText,
            errorText: errorText,
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        ),
      ],
    );
  }
}
