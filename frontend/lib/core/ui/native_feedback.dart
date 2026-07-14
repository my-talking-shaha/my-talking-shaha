import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/native_ui_platform.dart';

OverlayEntry? _activeMessage;
Timer? _activeMessageTimer;

void showNativeMessage(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  if (!usesCupertinoNativeUi(context)) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: duration));
    return;
  }

  _removeActiveMessage();
  final overlay = Overlay.of(context, rootOverlay: true);
  final theme = Theme.of(context);
  final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 20,
      right: 20,
      bottom: bottomInset + 20,
      child: SafeArea(
        top: false,
        child: Center(
          child: CupertinoPopupSurface(
            isSurfacePainted: false,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  _activeMessage = entry;
  overlay.insert(entry);
  _activeMessageTimer = Timer(duration, _removeActiveMessage);
}

void _removeActiveMessage() {
  _activeMessageTimer?.cancel();
  _activeMessageTimer = null;
  _activeMessage?.remove();
  _activeMessage = null;
}
