import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/native_ui_platform.dart';

Future<bool> showNativeConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  bool isDestructive = false,
}) async {
  if (usesCupertinoNativeUi(context)) {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(cancelLabel),
              ),
              CupertinoDialogAction(
                isDestructiveAction: isDestructive,
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            TextButton(
              style: isDestructive
                  ? TextButton.styleFrom(
                      foregroundColor: Theme.of(
                        dialogContext,
                      ).colorScheme.error,
                    )
                  : null,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}

Future<T?> showNativeFullscreenModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
}) {
  if (usesCupertinoNativeUi(context)) {
    return Navigator.of(context, rootNavigator: true).push<T>(
      CupertinoPageRoute<T>(
        fullscreenDialog: true,
        builder: (context) => Material(
          color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          child: builder(context),
        ),
      ),
    );
  }

  return showDialog<T>(
    context: context,
    barrierColor: backgroundColor,
    builder: (context) => Dialog.fullscreen(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: builder(context),
    ),
  );
}
