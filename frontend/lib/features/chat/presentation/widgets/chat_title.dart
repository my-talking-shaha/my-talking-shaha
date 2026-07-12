import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/features/chat/presentation/widgets/common/chat_assistant_mark.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class ChatTitle extends StatelessWidget {
  const ChatTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        const ChatAssistantMark(size: 36, iconSize: 18),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.chatWithShaha,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                l10n.vehicleAiAssistant,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
