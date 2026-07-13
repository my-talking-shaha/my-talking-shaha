import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';

InputDecoration garageInputDecoration({
  required BuildContext context,
  required String hintText,
  String? errorText,
  Widget? suffixIcon,
  BoxConstraints? suffixIconConstraints,
}) {
  return InputDecoration(
    hintText: hintText,
    errorText: errorText,
    hintStyle: TextStyle(color: context.appColors.hint),
    suffixIcon: suffixIcon,
    suffixIconConstraints: suffixIconConstraints,
    filled: true,
    fillColor: context.appColors.formField,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.appColors.formBorder),
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
  );
}
