import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';

final class GarageFieldLabel extends StatelessWidget {
  const GarageFieldLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: context.appColors.primaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}
