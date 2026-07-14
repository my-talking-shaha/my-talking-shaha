import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/native_ui_platform.dart';

final class NativeActivityIndicator extends StatelessWidget {
  const NativeActivityIndicator({
    this.color,
    this.radius = 10,
    this.strokeWidth = 4,
    super.key,
  });

  final Color? color;
  final double radius;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    if (usesCupertinoNativeUi(context)) {
      return CupertinoActivityIndicator(color: color, radius: radius);
    }

    return CircularProgressIndicator(color: color, strokeWidth: strokeWidth);
  }
}

final class NativeSwitch extends StatelessWidget {
  const NativeSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(value: value, onChanged: onChanged);
  }
}

final class NativeRefreshIndicator extends StatelessWidget {
  const NativeRefreshIndicator({
    required this.onRefresh,
    required this.child,
    this.color,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      color: color,
      child: child,
    );
  }
}
