import 'package:flutter/material.dart';
import 'package:frontend/features/chat/presentation/colors.dart';

final class ChatAssistantMark extends StatelessWidget {
  const ChatAssistantMark(
      {required this.size, required this.iconSize, super.key});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ChatColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ChatColors.primary.withValues(alpha: 0.28),
              blurRadius: size * 0.28,
              spreadRadius: size * 0.08,
            ),
          ],
          border: Border.all(
            color: ChatColors.primaryLight.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          Icons.smart_toy_rounded,
          color: ChatColors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
