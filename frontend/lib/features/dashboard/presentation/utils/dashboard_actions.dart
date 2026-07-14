import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/ui/native_ui.dart';
import 'package:frontend/features/dashboard/di/dashboard_providers.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

abstract final class DashboardActions {
  static void goBack(
    BuildContext context, {
    required String vehicleId,
    required bool launchedFromChat,
  }) {
    context.go(launchedFromChat ? '/vehicle/$vehicleId/chat' : '/garage');
  }

  static void openHistory(BuildContext context, String vehicleId) {
    context.go('/vehicle/$vehicleId/history');
  }

  static void retry(WidgetRef ref, String vehicleId) {
    unawaited(ref.refresh(vehicleDashboardProvider(vehicleId).future));
  }

  static Future<void> copyVin(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;

    showNativeMessage(context, AppLocalizations.of(context).vinCopied);
  }
}
