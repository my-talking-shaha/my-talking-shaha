import 'package:flutter/material.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';

final class GarageFieldLabel extends StatelessWidget {
  const GarageFieldLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: GarageColors.primaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}
