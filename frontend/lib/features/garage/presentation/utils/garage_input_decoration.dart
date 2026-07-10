import 'package:flutter/material.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';

InputDecoration garageInputDecoration({
  required String hintText,
  String? errorText,
  Widget? suffixIcon,
  BoxConstraints? suffixIconConstraints,
}) {
  return InputDecoration(
    hintText: hintText,
    errorText: errorText,
    hintStyle: const TextStyle(color: GarageColors.hint),
    suffixIcon: suffixIcon,
    suffixIconConstraints: suffixIconConstraints,
    filled: true,
    fillColor: GarageColors.formField,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: GarageColors.formBorder),
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
  );
}
