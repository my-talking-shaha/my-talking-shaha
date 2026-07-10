import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/features/garage/presentation/garage_colors.dart';

final class GarageSubmitButton extends StatelessWidget {
  const GarageSubmitButton({
    required this.label,
    required this.isSubmitting,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: GarageColors.formPrimary,
          foregroundColor: GarageColors.white,
          disabledBackgroundColor: GarageColors.formPrimary.withValues(
            alpha: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 12,
          shadowColor: GarageColors.formPrimary,
        ),
        onPressed: isSubmitting ? null : onPressed,
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/garage/rocket.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
