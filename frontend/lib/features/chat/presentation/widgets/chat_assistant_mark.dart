import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';

final class ChatAssistantMark extends StatelessWidget {
  const ChatAssistantMark({
    required this.size,
    required this.iconSize,
    super.key,
  });

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: size * 0.28,
              spreadRadius: size * 0.08,
            ),
          ],
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          Icons.smart_toy_rounded,
          color: AppColors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
