import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/features/chat/domain/entities/chat_action.dart';
import 'package:frontend/features/chat/presentation/utils/chat_action_presentation.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class ChatActionPill extends StatelessWidget {
  const ChatActionPill({
    required this.vehicleId,
    required this.action,
    super.key,
  });

  final String vehicleId;
  final ChatAction action;

  @override
  Widget build(BuildContext context) {
    final destination = chatActionDestination(vehicleId, action);
    if (destination == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: context.appColors.transparent,
        child: InkWell(
          key: const ValueKey('chat_message_action'),
          onTap: () =>
              openChatAction(context, action: action, destination: destination),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(7, 5, 12, 5),
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.appColors.primaryLight.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    chatActionIcon(action),
                    size: 14,
                    color: context.appColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  chatActionLabel(AppLocalizations.of(context), action),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.appColors.primaryLight,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
