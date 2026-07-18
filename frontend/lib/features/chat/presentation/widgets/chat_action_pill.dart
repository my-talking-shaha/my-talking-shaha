import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme/app_palette.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/chat/domain/entities/chat_action.dart';
import 'package:frontend/features/chat/presentation/utils/chat_action_presentation.dart';
import 'package:frontend/features/history/di/history_providers.dart';
import 'package:frontend/features/history/domain/entities/history_event.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final class ChatActionPill extends ConsumerWidget {
  const ChatActionPill({
    required this.vehicleId,
    required this.action,
    super.key,
  });

  final String vehicleId;
  final ChatAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = chatActionDestination(vehicleId, action);
    if (destination == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: context.appColors.transparent,
        child: InkWell(
          key: const ValueKey('chat_message_action'),
          onTap: () => _openAction(context, ref, destination),
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

  Future<void> _openAction(
    BuildContext context,
    WidgetRef ref,
    String destination,
  ) async {
    if (!_opensHistoryEventEditor) {
      openChatAction(context, destination: destination);
      return;
    }

    final eventId = action.prefill['eventId']?.toString().trim();
    if (eventId == null || eventId.isEmpty) return;

    HistoryEvent? event;
    try {
      final events = await ref.read(historyEventsProvider(vehicleId).future);
      for (final candidate in events) {
        if (candidate.id == eventId) {
          event = candidate;
          break;
        }
      }
    } catch (_) {
      if (context.mounted) {
        showNativeMessage(
          context,
          AppLocalizations.of(context).couldNotLoadHistory,
        );
      }
      return;
    }

    if (!context.mounted) return;
    if (event == null) {
      showNativeMessage(context, AppLocalizations.of(context).eventNotFound);
      return;
    }

    openChatAction(context, destination: destination, extra: event);
  }

  bool get _opensHistoryEventEditor {
    return action.type.toUpperCase() == 'OPEN_SCREEN' &&
        action.screen?.toUpperCase() == 'HISTORY_EVENT_EDIT';
  }
}
