import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/chat/di/chat_providers.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

void sendChatMessage({
  required WidgetRef ref,
  required String vehicleId,
  required TextEditingController messageController,
  required String text,
}) {
  final trimmedText = text.trim();
  if (trimmedText.isEmpty) return;

  messageController.clear();
  unawaited(
    ref.read(chatControllerProvider(vehicleId).notifier).send(trimmedText),
  );
}

void scrollChatToLatest(ScrollController controller) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!controller.hasClients) return;
    unawaited(
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    );
  });
}

String localizedChatError(AppLocalizations l10n, String message) {
  return switch (message) {
    'Could not get a reply. Check the backend and try again.' =>
      l10n.couldNotGetReply,
    _ => message,
  };
}
